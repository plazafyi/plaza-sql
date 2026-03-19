ALTER TYPE plaza_query.overpass_query
  ADD ATTRIBUTE data TEXT;

CREATE OR REPLACE FUNCTION plaza_query.make_overpass_query(data TEXT)
RETURNS plaza_query.overpass_query
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(data)::plaza_query.overpass_query;
$$;

ALTER TYPE plaza_query.sparql_query
  ADD ATTRIBUTE query TEXT;

CREATE OR REPLACE FUNCTION plaza_query.make_sparql_query(query TEXT)
RETURNS plaza_query.sparql_query
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(query)::plaza_query.sparql_query;
$$;

ALTER TYPE plaza_query.sparql_result
  ADD ATTRIBUTE features plaza.geo_json_feature[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_query.make_sparql_result(
  features plaza.geo_json_feature[], type TEXT
)
RETURNS plaza_query.sparql_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, type)::plaza_query.sparql_result;
$$;

CREATE OR REPLACE FUNCTION plaza_query._overpass(data TEXT)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.query.with_raw_response.overpass(
      data=data,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_query.overpass(data TEXT)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection, plaza_query._overpass(data)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_query._sparql(query TEXT)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.query.with_raw_response.sparql(
      query=query,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_query.sparql(query TEXT)
RETURNS plaza_query.sparql_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_query.sparql_result, plaza_query._sparql(query)
    );
  END;
$$;