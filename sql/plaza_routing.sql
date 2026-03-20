ALTER TYPE plaza_routing.matrix_request
  ADD ATTRIBUTE destinations plaza_routing.matrix_request_destination[],
  ADD ATTRIBUTE origins plaza_routing.matrix_request_origin[],
  ADD ATTRIBUTE annotations TEXT,
  ADD ATTRIBUTE fallback_speed DOUBLE PRECISION,
  ADD ATTRIBUTE mode TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_matrix_request(
  destinations plaza_routing.matrix_request_destination[],
  origins plaza_routing.matrix_request_origin[],
  annotations TEXT DEFAULT NULL,
  fallback_speed DOUBLE PRECISION DEFAULT NULL,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_routing.matrix_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    destinations, origins, annotations, fallback_speed, mode
  )::plaza_routing.matrix_request;
$$;

ALTER TYPE plaza_routing.matrix_request_destination
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_matrix_request_destination(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.matrix_request_destination
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.matrix_request_destination;
$$;

ALTER TYPE plaza_routing.matrix_request_origin
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_matrix_request_origin(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.matrix_request_origin
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.matrix_request_origin;
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
  ADD ATTRIBUTE distance_m DOUBLE PRECISION,
  ADD ATTRIBUTE edge_id BIGINT,
  ADD ATTRIBUTE edge_length_m DOUBLE PRECISION,
  ADD ATTRIBUTE highway TEXT,
  ADD ATTRIBUTE osm_way_id BIGINT,
  ADD ATTRIBUTE surface TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_nearest_result_property(
  distance_m DOUBLE PRECISION DEFAULT NULL,
  edge_id BIGINT DEFAULT NULL,
  edge_length_m DOUBLE PRECISION DEFAULT NULL,
  highway TEXT DEFAULT NULL,
  osm_way_id BIGINT DEFAULT NULL,
  surface TEXT DEFAULT NULL
)
RETURNS plaza_routing.nearest_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    distance_m, edge_id, edge_length_m, highway, osm_way_id, surface
  )::plaza_routing.nearest_result_property;
$$;

ALTER TYPE plaza_routing.route_request
  ADD ATTRIBUTE destination plaza_routing.route_request_destination,
  ADD ATTRIBUTE origin plaza_routing.route_request_origin,
  ADD ATTRIBUTE alternatives BIGINT,
  ADD ATTRIBUTE annotations BOOLEAN,
  ADD ATTRIBUTE depart_at TIMESTAMP,
  ADD ATTRIBUTE ev plaza_routing.route_request_ev,
  ADD ATTRIBUTE exclude TEXT,
  ADD ATTRIBUTE geometries TEXT,
  ADD ATTRIBUTE mode TEXT,
  ADD ATTRIBUTE overview TEXT,
  ADD ATTRIBUTE steps BOOLEAN,
  ADD ATTRIBUTE traffic_model TEXT,
  ADD ATTRIBUTE waypoints plaza_routing.route_request_waypoint[];

CREATE OR REPLACE FUNCTION plaza_routing.make_route_request(
  destination plaza_routing.route_request_destination,
  origin plaza_routing.route_request_origin,
  alternatives BIGINT DEFAULT NULL,
  annotations BOOLEAN DEFAULT NULL,
  depart_at TIMESTAMP DEFAULT NULL,
  ev plaza_routing.route_request_ev DEFAULT NULL,
  exclude TEXT DEFAULT NULL,
  geometries TEXT DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  overview TEXT DEFAULT NULL,
  steps BOOLEAN DEFAULT NULL,
  traffic_model TEXT DEFAULT NULL,
  waypoints plaza_routing.route_request_waypoint[] DEFAULT NULL
)
RETURNS plaza_routing.route_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    destination,
    origin,
    alternatives,
    annotations,
    depart_at,
    ev,
    exclude,
    geometries,
    mode,
    overview,
    steps,
    traffic_model,
    waypoints
  )::plaza_routing.route_request;
$$;

ALTER TYPE plaza_routing.route_request_destination
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_request_destination(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.route_request_destination
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.route_request_destination;
$$;

ALTER TYPE plaza_routing.route_request_origin
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_request_origin(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.route_request_origin
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.route_request_origin;
$$;

ALTER TYPE plaza_routing.route_request_ev
  ADD ATTRIBUTE battery_capacity_wh DOUBLE PRECISION,
  ADD ATTRIBUTE connector_types TEXT[],
  ADD ATTRIBUTE initial_charge_pct DOUBLE PRECISION,
  ADD ATTRIBUTE min_charge_pct DOUBLE PRECISION,
  ADD ATTRIBUTE min_power_kw DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_request_ev(
  battery_capacity_wh DOUBLE PRECISION,
  connector_types TEXT[] DEFAULT NULL,
  initial_charge_pct DOUBLE PRECISION DEFAULT NULL,
  min_charge_pct DOUBLE PRECISION DEFAULT NULL,
  min_power_kw DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_routing.route_request_ev
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    battery_capacity_wh,
    connector_types,
    initial_charge_pct,
    min_charge_pct,
    min_power_kw
  )::plaza_routing.route_request_ev;
$$;

ALTER TYPE plaza_routing.route_request_waypoint
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_request_waypoint(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.route_request_waypoint
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.route_request_waypoint;
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
  ADD ATTRIBUTE distance_m DOUBLE PRECISION,
  ADD ATTRIBUTE duration_s DOUBLE PRECISION,
  ADD ATTRIBUTE annotations JSONB,
  ADD ATTRIBUTE charge_profile DOUBLE PRECISION[][],
  ADD ATTRIBUTE charging_stops JSONB[],
  ADD ATTRIBUTE edges JSONB[],
  ADD ATTRIBUTE energy_used_wh DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_result_property(
  distance_m DOUBLE PRECISION,
  duration_s DOUBLE PRECISION,
  annotations JSONB DEFAULT NULL,
  charge_profile DOUBLE PRECISION[][] DEFAULT NULL,
  charging_stops JSONB[] DEFAULT NULL,
  edges JSONB[] DEFAULT NULL,
  energy_used_wh DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_routing.route_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    distance_m,
    duration_s,
    annotations,
    charge_profile,
    charging_stops,
    edges,
    energy_used_wh
  )::plaza_routing.route_result_property;
$$;

ALTER TYPE plaza_routing.routing_isochrone_response
  ADD ATTRIBUTE features plaza.geo_json_feature[],
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_routing.routing_isochrone_response_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_routing_isochrone_response(
  features plaza.geo_json_feature[] DEFAULT NULL,
  geometry plaza.geo_json_geometry DEFAULT NULL,
  properties plaza_routing.routing_isochrone_response_property DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS plaza_routing.routing_isochrone_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    features, geometry, properties, type
  )::plaza_routing.routing_isochrone_response;
$$;

ALTER TYPE plaza_routing.routing_isochrone_response_property
  ADD ATTRIBUTE area_m2 DOUBLE PRECISION,
  ADD ATTRIBUTE max_cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE mode TEXT,
  ADD ATTRIBUTE time_seconds DOUBLE PRECISION,
  ADD ATTRIBUTE vertices_reached BIGINT;

CREATE OR REPLACE FUNCTION plaza_routing.make_routing_isochrone_response_property(
  area_m2 DOUBLE PRECISION DEFAULT NULL,
  max_cost_s DOUBLE PRECISION DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  time_seconds DOUBLE PRECISION DEFAULT NULL,
  vertices_reached BIGINT DEFAULT NULL
)
RETURNS plaza_routing.routing_isochrone_response_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    area_m2, max_cost_s, mode, time_seconds, vertices_reached
  )::plaza_routing.routing_isochrone_response_property;
$$;

ALTER TYPE plaza_routing.routing_isochrone_post_response
  ADD ATTRIBUTE features plaza.geo_json_feature[],
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_routing.routing_isochrone_post_response_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_routing.make_routing_isochrone_post_response(
  features plaza.geo_json_feature[] DEFAULT NULL,
  geometry plaza.geo_json_geometry DEFAULT NULL,
  properties plaza_routing.routing_isochrone_post_response_property DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS plaza_routing.routing_isochrone_post_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    features, geometry, properties, type
  )::plaza_routing.routing_isochrone_post_response;
$$;

ALTER TYPE plaza_routing.routing_isochrone_post_response_property
  ADD ATTRIBUTE area_m2 DOUBLE PRECISION,
  ADD ATTRIBUTE max_cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE mode TEXT,
  ADD ATTRIBUTE time_seconds DOUBLE PRECISION,
  ADD ATTRIBUTE vertices_reached BIGINT;

CREATE OR REPLACE FUNCTION plaza_routing.make_routing_isochrone_post_response_property(
  area_m2 DOUBLE PRECISION DEFAULT NULL,
  max_cost_s DOUBLE PRECISION DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  time_seconds DOUBLE PRECISION DEFAULT NULL,
  vertices_reached BIGINT DEFAULT NULL
)
RETURNS plaza_routing.routing_isochrone_post_response_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    area_m2, max_cost_s, mode, time_seconds, vertices_reached
  )::plaza_routing.routing_isochrone_post_response_property;
$$;

ALTER TYPE plaza_routing.matrix_params_destination
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_matrix_params_destination(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.matrix_params_destination
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.matrix_params_destination;
$$;

ALTER TYPE plaza_routing.matrix_params_origin
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_matrix_params_origin(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.matrix_params_origin
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.matrix_params_origin;
$$;

ALTER TYPE plaza_routing.route_params_destination
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_params_destination(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.route_params_destination
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.route_params_destination;
$$;

ALTER TYPE plaza_routing.route_params_origin
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_params_origin(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.route_params_origin
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.route_params_origin;
$$;

ALTER TYPE plaza_routing.route_params_ev
  ADD ATTRIBUTE battery_capacity_wh DOUBLE PRECISION,
  ADD ATTRIBUTE connector_types TEXT[],
  ADD ATTRIBUTE initial_charge_pct DOUBLE PRECISION,
  ADD ATTRIBUTE min_charge_pct DOUBLE PRECISION,
  ADD ATTRIBUTE min_power_kw DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_params_ev(
  battery_capacity_wh DOUBLE PRECISION,
  connector_types TEXT[] DEFAULT NULL,
  initial_charge_pct DOUBLE PRECISION DEFAULT NULL,
  min_charge_pct DOUBLE PRECISION DEFAULT NULL,
  min_power_kw DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_routing.route_params_ev
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    battery_capacity_wh,
    connector_types,
    initial_charge_pct,
    min_charge_pct,
    min_power_kw
  )::plaza_routing.route_params_ev;
$$;

ALTER TYPE plaza_routing.route_params_waypoint
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_routing.make_route_params_waypoint(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_routing.route_params_waypoint
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_routing.route_params_waypoint;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._isochrone(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "time" DOUBLE PRECISION,
  format TEXT DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL
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
      format=not_given if format is None else format,
      mode=not_given if mode is None else mode,
      output_fields=not_given if output_fields is None else output_fields,
      output_geometry=not_given if output_geometry is None else output_geometry,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_simplify=not_given if output_simplify is None else output_simplify,
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
  format TEXT DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_routing.routing_isochrone_response
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.routing_isochrone_response,
      plaza_routing._isochrone(
        lat,
        lng,
        "time",
        format,
        mode,
        output_fields,
        output_geometry,
        output_include,
        output_precision,
        output_simplify
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._isochrone_post(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "time" DOUBLE PRECISION,
  format TEXT DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.isochrone_post(
      lat=lat,
      lng=lng,
      time=time,
      format=not_given if format is None else format,
      mode=not_given if mode is None else mode,
      output_fields=not_given if output_fields is None else output_fields,
      output_geometry=not_given if output_geometry is None else output_geometry,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_simplify=not_given if output_simplify is None else output_simplify,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.isochrone_post(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "time" DOUBLE PRECISION,
  format TEXT DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_routing.routing_isochrone_post_response
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.routing_isochrone_post_response,
      plaza_routing._isochrone_post(
        lat,
        lng,
        "time",
        format,
        mode,
        output_fields,
        output_geometry,
        output_include,
        output_precision,
        output_simplify
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._matrix(
  destinations plaza_routing.matrix_params_destination[],
  origins plaza_routing.matrix_params_origin[],
  annotations TEXT DEFAULT NULL,
  fallback_speed DOUBLE PRECISION DEFAULT NULL,
  mode TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.matrix(
      destinations=GD["__plaza_context__"].strip_none(destinations),
      origins=GD["__plaza_context__"].strip_none(origins),
      annotations=not_given if annotations is None else annotations,
      fallback_speed=not_given if fallback_speed is None else fallback_speed,
      mode=not_given if mode is None else mode,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.matrix(
  destinations plaza_routing.matrix_params_destination[],
  origins plaza_routing.matrix_params_origin[],
  annotations TEXT DEFAULT NULL,
  fallback_speed DOUBLE PRECISION DEFAULT NULL,
  mode TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN plaza_routing._matrix(
      destinations, origins, annotations, fallback_speed, mode
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._nearest(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.nearest(
      lat=lat,
      lng=lng,
      output_fields=not_given if output_fields is None else output_fields,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.nearest(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS plaza_routing.nearest_result
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.nearest_result,
      plaza_routing._nearest(
        lat, lng, output_fields, output_include, output_precision, radius
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._nearest_post(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.nearest_post(
      lat=lat,
      lng=lng,
      output_fields=not_given if output_fields is None else output_fields,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.nearest_post(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS plaza_routing.nearest_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.nearest_result,
      plaza_routing._nearest_post(
        lat, lng, output_fields, output_include, output_precision, radius
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_routing._route(
  destination plaza_routing.route_params_destination,
  origin plaza_routing.route_params_origin,
  format TEXT DEFAULT NULL,
  alternatives BIGINT DEFAULT NULL,
  annotations BOOLEAN DEFAULT NULL,
  depart_at TIMESTAMP DEFAULT NULL,
  ev plaza_routing.route_params_ev DEFAULT NULL,
  exclude TEXT DEFAULT NULL,
  geometries TEXT DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  overview TEXT DEFAULT NULL,
  steps BOOLEAN DEFAULT NULL,
  traffic_model TEXT DEFAULT NULL,
  waypoints plaza_routing.route_params_waypoint[] DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.routing.with_raw_response.route(
      destination=GD["__plaza_context__"].strip_none(destination),
      origin=GD["__plaza_context__"].strip_none(origin),
      format=not_given if format is None else format,
      alternatives=not_given if alternatives is None else alternatives,
      annotations=not_given if annotations is None else annotations,
      depart_at=not_given if depart_at is None else depart_at,
      ev=not_given if ev is None else GD["__plaza_context__"].strip_none(ev),
      exclude=not_given if exclude is None else exclude,
      geometries=not_given if geometries is None else geometries,
      mode=not_given if mode is None else mode,
      overview=not_given if overview is None else overview,
      steps=not_given if steps is None else steps,
      traffic_model=not_given if traffic_model is None else traffic_model,
      waypoints=not_given if waypoints is None else GD["__plaza_context__"].strip_none(waypoints),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_routing.route(
  destination plaza_routing.route_params_destination,
  origin plaza_routing.route_params_origin,
  format TEXT DEFAULT NULL,
  alternatives BIGINT DEFAULT NULL,
  annotations BOOLEAN DEFAULT NULL,
  depart_at TIMESTAMP DEFAULT NULL,
  ev plaza_routing.route_params_ev DEFAULT NULL,
  exclude TEXT DEFAULT NULL,
  geometries TEXT DEFAULT NULL,
  mode TEXT DEFAULT NULL,
  overview TEXT DEFAULT NULL,
  steps BOOLEAN DEFAULT NULL,
  traffic_model TEXT DEFAULT NULL,
  waypoints plaza_routing.route_params_waypoint[] DEFAULT NULL
)
RETURNS plaza_routing.route_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_routing.route_result,
      plaza_routing._route(
        destination,
        origin,
        format,
        alternatives,
        annotations,
        depart_at,
        ev,
        exclude,
        geometries,
        mode,
        overview,
        steps,
        traffic_model,
        waypoints
      )
    );
  END;
$$;