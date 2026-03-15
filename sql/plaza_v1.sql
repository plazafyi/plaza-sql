ALTER TYPE plaza_v1.v1_calculate_distance_matrix_response
  ADD ATTRIBUTE distances DOUBLE PRECISION[][],
  ADD ATTRIBUTE durations DOUBLE PRECISION[][];

CREATE OR REPLACE FUNCTION plaza_v1.make_v1_calculate_distance_matrix_response(
  distances DOUBLE PRECISION[][], durations DOUBLE PRECISION[][]
)
RETURNS plaza_v1.v1_calculate_distance_matrix_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    distances, durations
  )::plaza_v1.v1_calculate_distance_matrix_response;
$$;

ALTER TYPE plaza_v1.v1_calculate_route_response
  ADD ATTRIBUTE geometry plaza_v1_elements.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_v1.v1_calculate_route_response_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_v1.make_v1_calculate_route_response(
  geometry plaza_v1_elements.geo_json_geometry,
  properties plaza_v1.v1_calculate_route_response_property,
  type TEXT
)
RETURNS plaza_v1.v1_calculate_route_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry, properties, type)::plaza_v1.v1_calculate_route_response;
$$;

ALTER TYPE plaza_v1.v1_calculate_route_response_property
  ADD ATTRIBUTE distance DOUBLE PRECISION,
  ADD ATTRIBUTE duration DOUBLE PRECISION,
  ADD ATTRIBUTE mode TEXT;

CREATE OR REPLACE FUNCTION plaza_v1.make_v1_calculate_route_response_property(
  distance DOUBLE PRECISION DEFAULT NULL,
  duration DOUBLE PRECISION DEFAULT NULL,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_v1.v1_calculate_route_response_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    distance, duration, mode
  )::plaza_v1.v1_calculate_route_response_property;
$$;

ALTER TYPE plaza_v1.v1_execute_sparql_response
  ADD ATTRIBUTE results plaza_v1_elements.geo_json_feature[];

CREATE OR REPLACE FUNCTION plaza_v1.make_v1_execute_sparql_response(
  results plaza_v1_elements.geo_json_feature[]
)
RETURNS plaza_v1.v1_execute_sparql_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(results)::plaza_v1.v1_execute_sparql_response;
$$;

ALTER TYPE plaza_v1.v1_snap_to_nearest_response
  ADD ATTRIBUTE distance DOUBLE PRECISION,
  ADD ATTRIBUTE lat DOUBLE PRECISION,
  ADD ATTRIBUTE lng DOUBLE PRECISION,
  ADD ATTRIBUTE edge_id BIGINT;

CREATE OR REPLACE FUNCTION plaza_v1.make_v1_snap_to_nearest_response(
  distance DOUBLE PRECISION,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  edge_id BIGINT DEFAULT NULL
)
RETURNS plaza_v1.v1_snap_to_nearest_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(distance, lat, lng, edge_id)::plaza_v1.v1_snap_to_nearest_response;
$$;

ALTER TYPE plaza_v1.calculate_distance_matrix_params_destination
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_v1.make_calculate_distance_matrix_params_destination(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_v1.calculate_distance_matrix_params_destination
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_v1.calculate_distance_matrix_params_destination;
$$;

ALTER TYPE plaza_v1.calculate_distance_matrix_params_origin
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_v1.make_calculate_distance_matrix_params_origin(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_v1.calculate_distance_matrix_params_origin
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_v1.calculate_distance_matrix_params_origin;
$$;

ALTER TYPE plaza_v1.calculate_route_params_destination
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_v1.make_calculate_route_params_destination(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_v1.calculate_route_params_destination
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_v1.calculate_route_params_destination;
$$;

ALTER TYPE plaza_v1.calculate_route_params_origin
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_v1.make_calculate_route_params_origin(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_v1.calculate_route_params_origin
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_v1.calculate_route_params_origin;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._calculate_distance_matrix(
  destinations plaza_v1.calculate_distance_matrix_params_destination[],
  origins plaza_v1.calculate_distance_matrix_params_origin[],
  mode TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.with_raw_response.calculate_distance_matrix(
      destinations=GD["__plaza_context__"].strip_none(destinations),
      origins=GD["__plaza_context__"].strip_none(origins),
      mode=not_given if mode is None else mode,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.calculate_distance_matrix(
  destinations plaza_v1.calculate_distance_matrix_params_destination[],
  origins plaza_v1.calculate_distance_matrix_params_origin[],
  mode TEXT DEFAULT NULL
)
RETURNS plaza_v1.v1_calculate_distance_matrix_response
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1.v1_calculate_distance_matrix_response,
      plaza_v1._calculate_distance_matrix(destinations, origins, mode)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._calculate_isochrone(
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

  response = GD["__plaza_context__"].client.v1.with_raw_response.calculate_isochrone(
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

CREATE OR REPLACE FUNCTION plaza_v1.calculate_isochrone(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "time" DOUBLE PRECISION,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_v1_elements.geo_json_feature
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_elements.geo_json_feature,
      plaza_v1._calculate_isochrone(lat, lng, "time", mode)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._calculate_route(
  destination plaza_v1.calculate_route_params_destination,
  origin plaza_v1.calculate_route_params_origin,
  mode TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.with_raw_response.calculate_route(
      destination=GD["__plaza_context__"].strip_none(destination),
      origin=GD["__plaza_context__"].strip_none(origin),
      mode=not_given if mode is None else mode,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.calculate_route(
  destination plaza_v1.calculate_route_params_destination,
  origin plaza_v1.calculate_route_params_origin,
  mode TEXT DEFAULT NULL
)
RETURNS plaza_v1.v1_calculate_route_response
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1.v1_calculate_route_response,
      plaza_v1._calculate_route(destination, origin, mode)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._execute_overpass(data TEXT)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.v1.with_raw_response.execute_overpass(
      data=data,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.execute_overpass(data TEXT)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.feature_collection,
      plaza_v1._execute_overpass(data)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._execute_query(
  bbox TEXT DEFAULT NULL, type TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.with_raw_response.execute_query(
      bbox=not_given if bbox is None else bbox,
      type=not_given if type is None else type,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.execute_query(
  bbox TEXT DEFAULT NULL, type TEXT DEFAULT NULL
)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.feature_collection,
      plaza_v1._execute_query(bbox, type)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._execute_sparql(query TEXT)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.v1.with_raw_response.execute_sparql(
      query=query,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.execute_sparql(query TEXT)
RETURNS plaza_v1.v1_execute_sparql_response
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1.v1_execute_sparql_response, plaza_v1._execute_sparql(query)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._find_nearby(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "limit" BIGINT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.with_raw_response.find_nearby(
      lat=lat,
      lng=lng,
      limit=not_given if limit is None else limit,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.find_nearby(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "limit" BIGINT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.feature_collection,
      plaza_v1._find_nearby(lat, lng, "limit", radius)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._get_tile(z BIGINT, x BIGINT, y BIGINT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.v1.with_raw_response.get_tile(
      z=z,
      x=x,
      y=y,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.get_tile(z BIGINT, x BIGINT, y BIGINT)
RETURNS BYTEA
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(NULL::BYTEA, plaza_v1._get_tile(z, x, y));
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._reverse_geocode(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.v1.with_raw_response.reverse_geocode(
      lat=lat,
      lng=lng,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.reverse_geocode(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_v1_elements.geo_json_feature
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_elements.geo_json_feature,
      plaza_v1._reverse_geocode(lat, lng)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._search_features(
  q TEXT, cursor TEXT DEFAULT NULL, "limit" BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.with_raw_response.search_features(
      q=q,
      cursor=not_given if cursor is None else cursor,
      limit=not_given if limit is None else limit,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.search_features(
  q TEXT, cursor TEXT DEFAULT NULL, "limit" BIGINT DEFAULT NULL
)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.feature_collection,
      plaza_v1._search_features(q, cursor, "limit")
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1._snap_to_nearest(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION, radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.with_raw_response.snap_to_nearest(
      lat=lat,
      lng=lng,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1.snap_to_nearest(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION, radius BIGINT DEFAULT NULL
)
RETURNS plaza_v1.v1_snap_to_nearest_response
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1.v1_snap_to_nearest_response,
      plaza_v1._snap_to_nearest(lat, lng, radius)
    );
  END;
$$;