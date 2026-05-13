ALTER TYPE plaza_elevation.elevation_lookup_request
  ADD ATTRIBUTE geometry plaza_elevation.elevation_lookup_request_geometry;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_lookup_request(
  geometry plaza_elevation.elevation_lookup_request_geometry
)
RETURNS plaza_elevation.elevation_lookup_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry)::plaza_elevation.elevation_lookup_request;
$$;

ALTER TYPE plaza_elevation.elevation_lookup_request_geometry
  ADD ATTRIBUTE coordinates JSONB[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_lookup_request_geometry(
  coordinates JSONB[], type TEXT
)
RETURNS plaza_elevation.elevation_lookup_request_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    coordinates, type
  )::plaza_elevation.elevation_lookup_request_geometry;
$$;

ALTER TYPE plaza_elevation.elevation_lookup_result
  ADD ATTRIBUTE geometry plaza.geometry,
  ADD ATTRIBUTE properties plaza_elevation.elevation_lookup_result_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_lookup_result(
  geometry plaza.geometry,
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
  elevation_m DOUBLE PRECISION
)
RETURNS plaza_elevation.elevation_lookup_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(elevation_m)::plaza_elevation.elevation_lookup_result_property;
$$;

ALTER TYPE plaza_elevation.elevation_profile_request
  ADD ATTRIBUTE geometry plaza.line_string_geometry;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_profile_request(
  geometry plaza.line_string_geometry
)
RETURNS plaza_elevation.elevation_profile_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry)::plaza_elevation.elevation_profile_request;
$$;

ALTER TYPE plaza_elevation.elevation_profile_result
  ADD ATTRIBUTE geometry plaza.geometry,
  ADD ATTRIBUTE properties plaza_elevation.elevation_profile_result_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_profile_result(
  geometry plaza.geometry,
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
  avg_elevation_m DOUBLE PRECISION,
  max_elevation_m DOUBLE PRECISION,
  min_elevation_m DOUBLE PRECISION,
  total_ascent_m DOUBLE PRECISION,
  total_descent_m DOUBLE PRECISION
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

ALTER TYPE plaza_elevation.lookup_params_geometry
  ADD ATTRIBUTE coordinates JSONB[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elevation.make_lookup_params_geometry(
  coordinates JSONB[], type TEXT
)
RETURNS plaza_elevation.lookup_params_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza_elevation.lookup_params_geometry;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._lookup(
  geometry plaza_elevation.lookup_params_geometry, format TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elevation.with_raw_response.lookup(
      geometry=GD["__plaza_context__"].strip_none(geometry),
      format=not_given if format is None else format,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.lookup(
  geometry plaza_elevation.lookup_params_geometry, format TEXT DEFAULT NULL
)
RETURNS plaza_elevation.elevation_lookup_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_lookup_result,
      plaza_elevation._lookup(geometry, format)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._profile(
  geometry plaza.line_string_geometry
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
  geometry plaza.line_string_geometry
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