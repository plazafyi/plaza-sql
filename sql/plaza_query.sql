ALTER TYPE plaza_query.plazaql_query
  ADD ATTRIBUTE data TEXT;

CREATE OR REPLACE FUNCTION plaza_query.make_plazaql_query(data TEXT)
RETURNS plaza_query.plazaql_query
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(data)::plaza_query.plazaql_query;
$$;

CREATE OR REPLACE FUNCTION plaza_query._execute(
  data TEXT, format TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.query.with_raw_response.execute(
      data=data,
      format=not_given if format is None else format,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_query.execute(
  data TEXT, format TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection, plaza_query._execute(data, format)
    );
  END;
$$;