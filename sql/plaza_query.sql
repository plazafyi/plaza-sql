ALTER TYPE plaza_query.overpass_query
  ADD ATTRIBUTE data TEXT;

CREATE OR REPLACE FUNCTION plaza_query.make_overpass_query(data TEXT)
RETURNS plaza_query.overpass_query
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(data)::plaza_query.overpass_query;
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

CREATE OR REPLACE FUNCTION plaza_query._overpass(
  data TEXT, format TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.query.with_raw_response.overpass(
      data=data,
      format=not_given if format is None else format,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_query.overpass(
  data TEXT, format TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection, plaza_query._overpass(data, format)
    );
  END;
$$;