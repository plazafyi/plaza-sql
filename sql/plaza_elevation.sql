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
  elevation_m DOUBLE PRECISION
)
RETURNS plaza_elevation.elevation_lookup_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(elevation_m)::plaza_elevation.elevation_lookup_result_property;
$$;

ALTER TYPE plaza_elevation.elevation_profile_request
  ADD ATTRIBUTE coordinates plaza_elevation.elevation_profile_request_coordinate[];

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_profile_request(
  coordinates plaza_elevation.elevation_profile_request_coordinate[]
)
RETURNS plaza_elevation.elevation_profile_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates)::plaza_elevation.elevation_profile_request;
$$;

ALTER TYPE plaza_elevation.elevation_profile_request_coordinate
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_elevation.make_elevation_profile_request_coordinate(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_elevation.elevation_profile_request_coordinate
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_elevation.elevation_profile_request_coordinate;
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

ALTER TYPE plaza_elevation.batch_params_coordinate
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_elevation.make_batch_params_coordinate(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_elevation.batch_params_coordinate
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_elevation.batch_params_coordinate;
$$;

ALTER TYPE plaza_elevation.profile_params_coordinate
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_elevation.make_profile_params_coordinate(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_elevation.profile_params_coordinate
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_elevation.profile_params_coordinate;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._batch(
  coordinates plaza_elevation.batch_params_coordinate[],
  format TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elevation.with_raw_response.batch(
      coordinates=GD["__plaza_context__"].strip_none(coordinates),
      format=not_given if format is None else format,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.batch(
  coordinates plaza_elevation.batch_params_coordinate[],
  format TEXT DEFAULT NULL
)
RETURNS plaza_elevation.elevation_batch_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_batch_result,
      plaza_elevation._batch(coordinates, format)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._lookup(
  format TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  locations TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elevation.with_raw_response.lookup(
      format=not_given if format is None else format,
      lat=not_given if lat is None else lat,
      lng=not_given if lng is None else lng,
      locations=not_given if locations is None else locations,
      output_fields=not_given if output_fields is None else output_fields,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.lookup(
  format TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  locations TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL
)
RETURNS plaza_elevation.elevation_lookup_result
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_lookup_result,
      plaza_elevation._lookup(
        format,
        lat,
        lng,
        locations,
        output_fields,
        output_include,
        output_precision
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._lookup_post(
  format TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  locations TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elevation.with_raw_response.lookup_post(
      format=not_given if format is None else format,
      lat=not_given if lat is None else lat,
      lng=not_given if lng is None else lng,
      locations=not_given if locations is None else locations,
      output_fields=not_given if output_fields is None else output_fields,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.lookup_post(
  format TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  locations TEXT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL
)
RETURNS plaza_elevation.elevation_lookup_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_lookup_result,
      plaza_elevation._lookup_post(
        format,
        lat,
        lng,
        locations,
        output_fields,
        output_include,
        output_precision
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elevation._profile(
  coordinates plaza_elevation.profile_params_coordinate[]
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.elevation.with_raw_response.profile(
      coordinates=GD["__plaza_context__"].strip_none(coordinates),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elevation.profile(
  coordinates plaza_elevation.profile_params_coordinate[]
)
RETURNS plaza_elevation.elevation_profile_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_elevation.elevation_profile_result,
      plaza_elevation._profile(coordinates)
    );
  END;
$$;