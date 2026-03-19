ALTER TYPE plaza_elevation.elevation_batch_result
  ADD ATTRIBUTE features plaza_elevation.elevation_lookup_result[],
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_batch_result(
  features plaza_elevation.elevation_lookup_result[], type TEXT
)
RETURNS plaza_elevation.elevation_batch_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, type)::plaza_elevation.elevation_batch_result;
$$;

ALTER TYPE plaza_elevation.elevation_lookup_result
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_elevation.elevation_lookup_result_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_lookup_result(
  geometry plaza.geo_json_geometry,
  properties plaza_elevation.elevation_lookup_result_property,
  type TEXT
)
RETURNS plaza_elevation.elevation_lookup_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, type
  )::plaza_elevation.elevation_lookup_result;
$$;

ALTER TYPE plaza_elevation.elevation_lookup_result_property
  ADD ATTRIBUTE elevation_m DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_lookup_result_property(
  elevation_m DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_elevation.elevation_lookup_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(elevation_m)::plaza_elevation.elevation_lookup_result_property;
$$;

ALTER TYPE plaza_elevation.elevation_profile_request
  ADD ATTRIBUTE geometry plaza.geo_json_geometry;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_profile_request(
  geometry plaza.geo_json_geometry
)
RETURNS plaza_elevation.elevation_profile_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry)::plaza_elevation.elevation_profile_request;
$$;

ALTER TYPE plaza_elevation.elevation_profile_result
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_elevation.elevation_profile_result_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_profile_result(
  geometry plaza.geo_json_geometry,
  properties plaza_elevation.elevation_profile_result_property,
  type TEXT
)
RETURNS plaza_elevation.elevation_profile_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, type
  )::plaza_elevation.elevation_profile_result;
$$;

ALTER TYPE plaza_elevation.elevation_profile_result_property
  ADD ATTRIBUTE avg_elevation_m DOUBLE PRECISION,
  ADD ATTRIBUTE max_elevation_m DOUBLE PRECISION,
  ADD ATTRIBUTE min_elevation_m DOUBLE PRECISION,
  ADD ATTRIBUTE total_ascent_m DOUBLE PRECISION,
  ADD ATTRIBUTE total_descent_m DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_profile_result_property(
  avg_elevation_m DOUBLE PRECISION DEFAULT NULL,
  max_elevation_m DOUBLE PRECISION DEFAULT NULL,
  min_elevation_m DOUBLE PRECISION DEFAULT NULL,
  total_ascent_m DOUBLE PRECISION DEFAULT NULL,
  total_descent_m DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_elevation.elevation_profile_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    avg_elevation_m,
    max_elevation_m,
    min_elevation_m,
    total_ascent_m,
    total_descent_m
  )::plaza_elevation.elevation_profile_result_property;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._batch(
  geometry plaza.geo_json_geometry
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.elevation.with_raw_response.batch(
      geometry=GD["__plaza_context__"].strip_none(geometry),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.batch(
  geometry plaza.geo_json_geometry
)
RETURNS plaza_elevation.elevation_batch_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_batch_result,
      plaza_elevation._batch(geometry)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._lookup(
  lat DOUBLE PRECISION DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  locations TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elevation.with_raw_response.lookup(
      lat=not_given if lat is None else lat,
      lng=not_given if lng is None else lng,
      locations=not_given if locations is None else locations,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.lookup(
  lat DOUBLE PRECISION DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  locations TEXT DEFAULT NULL
)
RETURNS plaza_elevation.elevation_lookup_result
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_lookup_result,
      plaza_elevation._lookup(lat, lng, locations)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._profile(
  geometry plaza.geo_json_geometry
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.elevation.with_raw_response.profile(
      geometry=GD["__plaza_context__"].strip_none(geometry),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.profile(
  geometry plaza.geo_json_geometry
)
RETURNS plaza_elevation.elevation_profile_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_profile_result,
      plaza_elevation._profile(geometry)
    );
  END;
$$;