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
  ADD ATTRIBUTE results plaza_query.sparql_result_result[];

CREATE OR REPLACE FUNCTION plaza_query.make_sparql_result(
  results plaza_query.sparql_result_result[]
)
RETURNS plaza_query.sparql_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(results)::plaza_query.sparql_result;
$$;

ALTER TYPE plaza_query.sparql_result_result
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties JSONB,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE id TEXT;

CREATE OR REPLACE FUNCTION plaza_query.make_sparql_result_result(
  geometry plaza.geo_json_geometry,
  properties JSONB,
  type TEXT,
  id TEXT DEFAULT NULL
)
RETURNS plaza_query.sparql_result_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry, properties, type, id)::plaza_query.sparql_result_result;
$$;

ALTER TYPE plaza_query.query_execute_response
  ADD ATTRIBUTE steps JSONB[];

CREATE OR REPLACE FUNCTION plaza_query.make_query_execute_response(
  steps JSONB[]
)
RETURNS plaza_query.query_execute_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(steps)::plaza_query.query_execute_response;
$$;

ALTER TYPE plaza_query.execute_params_step
  ADD ATTRIBUTE type TEXT, ADD ATTRIBUTE query TEXT;

CREATE OR REPLACE FUNCTION plaza_query.make_execute_params_step(
  type TEXT, query TEXT DEFAULT NULL
)
RETURNS plaza_query.execute_params_step
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(type, query)::plaza_query.execute_params_step;
$$;

CREATE OR REPLACE FUNCTION plaza_query._execute(
  steps plaza_query.execute_params_step[]
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.query.with_raw_response.execute(
      steps=GD["__plaza_context__"].strip_none(steps),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_query.execute(
  steps plaza_query.execute_params_step[]
)
RETURNS plaza_query.query_execute_response
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_query.query_execute_response, plaza_query._execute(steps)
    );
  END;
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