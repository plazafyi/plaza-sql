ALTER TYPE plaza_map_match.map_match_request
  ADD ATTRIBUTE trace plaza.geo_json_geometry,
  ADD ATTRIBUTE radiuses DOUBLE PRECISION[];

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_request(
  trace plaza.geo_json_geometry, radiuses DOUBLE PRECISION[] DEFAULT NULL
)
RETURNS plaza_map_match.map_match_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(trace, radiuses)::plaza_map_match.map_match_request;
$$;

ALTER TYPE plaza_map_match.map_match_result
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_map_match.map_match_result_property,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE legs JSONB[];

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_result(
  geometry plaza.geo_json_geometry,
  properties plaza_map_match.map_match_result_property,
  type TEXT,
  legs JSONB[] DEFAULT NULL
)
RETURNS plaza_map_match.map_match_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, type, legs
  )::plaza_map_match.map_match_result;
$$;

ALTER TYPE plaza_map_match.map_match_result_property
  ADD ATTRIBUTE confidence DOUBLE PRECISION,
  ADD ATTRIBUTE distance DOUBLE PRECISION,
  ADD ATTRIBUTE duration DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_result_property(
  confidence DOUBLE PRECISION DEFAULT NULL,
  distance DOUBLE PRECISION DEFAULT NULL,
  duration DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_map_match.map_match_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    confidence, distance, duration
  )::plaza_map_match.map_match_result_property;
$$;

CREATE OR REPLACE FUNCTION plaza_map_match._match(
  trace plaza.geo_json_geometry, radiuses DOUBLE PRECISION[] DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.map_match.with_raw_response.match(
      trace=GD["__plaza_context__"].strip_none(trace),
      radiuses=not_given if radiuses is None else radiuses,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_map_match.match(
  trace plaza.geo_json_geometry, radiuses DOUBLE PRECISION[] DEFAULT NULL
)
RETURNS plaza_map_match.map_match_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_map_match.map_match_result,
      plaza_map_match._match(trace, radiuses)
    );
  END;
$$;