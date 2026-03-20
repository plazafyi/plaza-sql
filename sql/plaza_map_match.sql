ALTER TYPE plaza_map_match.map_match_request
  ADD ATTRIBUTE coordinates plaza_map_match.map_match_request_coordinate[],
  ADD ATTRIBUTE radiuses DOUBLE PRECISION[];

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_request(
  coordinates plaza_map_match.map_match_request_coordinate[],
  radiuses DOUBLE PRECISION[] DEFAULT NULL
)
RETURNS plaza_map_match.map_match_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, radiuses)::plaza_map_match.map_match_request;
$$;

ALTER TYPE plaza_map_match.map_match_request_coordinate
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_request_coordinate(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_map_match.map_match_request_coordinate
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_map_match.map_match_request_coordinate;
$$;

ALTER TYPE plaza_map_match.map_match_result
  ADD ATTRIBUTE features plaza_map_match.map_match_result_feature[],
  ADD ATTRIBUTE matchings JSONB[],
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_result(
  features plaza_map_match.map_match_result_feature[],
  matchings JSONB[],
  type TEXT
)
RETURNS plaza_map_match.map_match_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, matchings, type)::plaza_map_match.map_match_result;
$$;

ALTER TYPE plaza_map_match.map_match_result_feature
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_map_match.map_match_result_feature_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_result_feature(
  geometry plaza.geo_json_geometry,
  properties plaza_map_match.map_match_result_feature_property,
  type TEXT
)
RETURNS plaza_map_match.map_match_result_feature
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, type
  )::plaza_map_match.map_match_result_feature;
$$;

ALTER TYPE plaza_map_match.map_match_result_feature_property
  ADD ATTRIBUTE distance_m DOUBLE PRECISION,
  ADD ATTRIBUTE edge_id BIGINT,
  ADD ATTRIBUTE matchings_index BIGINT,
  ADD ATTRIBUTE name TEXT,
  ADD ATTRIBUTE original DOUBLE PRECISION[],
  ADD ATTRIBUTE waypoint_index BIGINT;

CREATE OR REPLACE FUNCTION plaza_map_match.make_map_match_result_feature_property(
  distance_m DOUBLE PRECISION DEFAULT NULL,
  edge_id BIGINT DEFAULT NULL,
  matchings_index BIGINT DEFAULT NULL,
  name TEXT DEFAULT NULL,
  original DOUBLE PRECISION[] DEFAULT NULL,
  waypoint_index BIGINT DEFAULT NULL
)
RETURNS plaza_map_match.map_match_result_feature_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    distance_m, edge_id, matchings_index, name, original, waypoint_index
  )::plaza_map_match.map_match_result_feature_property;
$$;

ALTER TYPE plaza_map_match.match_params_coordinate
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_map_match.make_match_params_coordinate(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_map_match.match_params_coordinate
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_map_match.match_params_coordinate;
$$;

CREATE OR REPLACE FUNCTION plaza_map_match._match(
  coordinates plaza_map_match.match_params_coordinate[],
  radiuses DOUBLE PRECISION[] DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.map_match.with_raw_response.match(
      coordinates=GD["__plaza_context__"].strip_none(coordinates),
      radiuses=not_given if radiuses is None else radiuses,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_map_match.match(
  coordinates plaza_map_match.match_params_coordinate[],
  radiuses DOUBLE PRECISION[] DEFAULT NULL
)
RETURNS plaza_map_match.map_match_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_map_match.map_match_result,
      plaza_map_match._match(coordinates, radiuses)
    );
  END;
$$;