ALTER TYPE plaza_routing.matrix_request
  ADD ATTRIBUTE destinations plaza.geo_json_geometry,
  ADD ATTRIBUTE origins plaza.geo_json_geometry,
  ADD ATTRIBUTE mode TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_matrix_request(
  destinations plaza.geo_json_geometry,
  origins plaza.geo_json_geometry,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_routing.matrix_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(destinations, origins, mode)::plaza_routing.matrix_request;
$$;

ALTER TYPE plaza_routing.matrix_result
  ADD ATTRIBUTE distances DOUBLE PRECISION[][],
  ADD ATTRIBUTE durations DOUBLE PRECISION[][];

CREATE OR REPLACE FUNCTION plaza_routing.make_matrix_result(
  distances DOUBLE PRECISION[][], durations DOUBLE PRECISION[][]
)
RETURNS plaza_routing.matrix_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(distances, durations)::plaza_routing.matrix_result;
$$;

ALTER TYPE plaza_routing.nearest_result
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_routing.nearest_result_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_nearest_result(
  geometry plaza.geo_json_geometry,
  properties plaza_routing.nearest_result_property,
  type TEXT
)
RETURNS plaza_routing.nearest_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry, properties, type)::plaza_routing.nearest_result;
$$;

ALTER TYPE plaza_routing.nearest_result_property
  ADD ATTRIBUTE distance_m DOUBLE PRECISION, ADD ATTRIBUTE edge_id BIGINT;

CREATE OR REPLACE FUNCTION plaza_routing.make_nearest_result_property(
  distance_m DOUBLE PRECISION DEFAULT NULL, edge_id BIGINT DEFAULT NULL
)
RETURNS plaza_routing.nearest_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(distance_m, edge_id)::plaza_routing.nearest_result_property;
$$;

ALTER TYPE plaza_routing.route_request
  ADD ATTRIBUTE destination plaza.geo_json_geometry,
  ADD ATTRIBUTE origin plaza.geo_json_geometry,
  ADD ATTRIBUTE mode TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_request(
  destination plaza.geo_json_geometry,
  origin plaza.geo_json_geometry,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_routing.route_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(destination, origin, mode)::plaza_routing.route_request;
$$;

ALTER TYPE plaza_routing.route_result
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_routing.route_result_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_result(
  geometry plaza.geo_json_geometry,
  properties plaza_routing.route_result_property,
  type TEXT
)
RETURNS plaza_routing.route_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry, properties, type)::plaza_routing.route_result;
$$;

ALTER TYPE plaza_routing.route_result_property
  ADD ATTRIBUTE distance DOUBLE PRECISION,
  ADD ATTRIBUTE duration DOUBLE PRECISION,
  ADD ATTRIBUTE mode TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_result_property(
  distance DOUBLE PRECISION DEFAULT NULL,
  duration DOUBLE PRECISION DEFAULT NULL,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_routing.route_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(distance, duration, mode)::plaza_routing.route_result_property;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._isochrone(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "time" DOUBLE PRECISION,
  mode TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.isochrone(
      lat=lat,
      lng=lng,
      time=time,
      mode=not_given if mode is None else mode,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.isochrone(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "time" DOUBLE PRECISION,
  mode TEXT DEFAULT NULL
)
RETURNS plaza.geo_json_feature
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.geo_json_feature,
      plaza_routing._isochrone(lat, lng, "time", mode)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._matrix(
  destinations plaza.geo_json_geometry,
  origins plaza.geo_json_geometry,
  mode TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.matrix(
      destinations=GD["__plaza_context__"].strip_none(destinations),
      origins=GD["__plaza_context__"].strip_none(origins),
      mode=not_given if mode is None else mode,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.matrix(
  destinations plaza.geo_json_geometry,
  origins plaza.geo_json_geometry,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_routing.matrix_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.matrix_result,
      plaza_routing._matrix(destinations, origins, mode)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._nearest(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION, radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.nearest(
      lat=lat,
      lng=lng,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.nearest(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION, radius BIGINT DEFAULT NULL
)
RETURNS plaza_routing.nearest_result
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.nearest_result,
      plaza_routing._nearest(lat, lng, radius)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._route(
  destination plaza.geo_json_geometry,
  origin plaza.geo_json_geometry,
  mode TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.route(
      destination=GD["__plaza_context__"].strip_none(destination),
      origin=GD["__plaza_context__"].strip_none(origin),
      mode=not_given if mode is None else mode,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.route(
  destination plaza.geo_json_geometry,
  origin plaza.geo_json_geometry,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_routing.route_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.route_result,
      plaza_routing._route(destination, origin, mode)
    );
  END;
$$;