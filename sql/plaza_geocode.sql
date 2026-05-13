ALTER TYPE plaza_geocode.autocomplete_request
  ADD ATTRIBUTE q TEXT,
  ADD ATTRIBUTE country_code TEXT,
  ADD ATTRIBUTE focus plaza.point_geometry,
  ADD ATTRIBUTE lang TEXT,
  ADD ATTRIBUTE layer TEXT,
  ADD ATTRIBUTE "limit" BIGINT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_autocomplete_request(
  q TEXT,
  country_code TEXT DEFAULT NULL,
  focus plaza.point_geometry DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL
)
RETURNS plaza_geocode.autocomplete_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    q, country_code, focus, lang, layer, "limit"
  )::plaza_geocode.autocomplete_request;
$$;

ALTER TYPE plaza_geocode.autocomplete_result
  ADD ATTRIBUTE features plaza_geocode.geocoding_feature[],
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_autocomplete_result(
  features plaza_geocode.geocoding_feature[], type TEXT
)
RETURNS plaza_geocode.autocomplete_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, type)::plaza_geocode.autocomplete_result;
$$;

ALTER TYPE plaza_geocode.geocode_forward_request
  ADD ATTRIBUTE q TEXT,
  ADD ATTRIBUTE country_code TEXT,
  ADD ATTRIBUTE focus plaza.point_geometry,
  ADD ATTRIBUTE lang TEXT,
  ADD ATTRIBUTE layer TEXT,
  ADD ATTRIBUTE "limit" BIGINT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_geocode_forward_request(
  q TEXT,
  country_code TEXT DEFAULT NULL,
  focus plaza.point_geometry DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL
)
RETURNS plaza_geocode.geocode_forward_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    q, country_code, focus, lang, layer, "limit"
  )::plaza_geocode.geocode_forward_request;
$$;

ALTER TYPE plaza_geocode.geocode_result
  ADD ATTRIBUTE features plaza_geocode.geocoding_feature[],
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_geocode_result(
  features plaza_geocode.geocoding_feature[], type TEXT
)
RETURNS plaza_geocode.geocode_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, type)::plaza_geocode.geocode_result;
$$;

ALTER TYPE plaza_geocode.geocode_reverse_request
  ADD ATTRIBUTE geometry plaza.point_geometry,
  ADD ATTRIBUTE lang TEXT,
  ADD ATTRIBUTE "limit" BIGINT,
  ADD ATTRIBUTE radius DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_geocode.make_geocode_reverse_request(
  geometry plaza.point_geometry,
  lang TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_geocode.geocode_reverse_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, lang, "limit", radius
  )::plaza_geocode.geocode_reverse_request;
$$;

ALTER TYPE plaza_geocode.geocoding_feature
  ADD ATTRIBUTE geometry plaza.geometry,
  ADD ATTRIBUTE properties plaza_geocode.geocoding_feature_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_geocoding_feature(
  geometry plaza.geometry,
  properties plaza_geocode.geocoding_feature_property,
  type TEXT
)
RETURNS plaza_geocode.geocoding_feature
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry, properties, type)::plaza_geocode.geocoding_feature;
$$;

ALTER TYPE plaza_geocode.geocoding_feature_property
  ADD ATTRIBUTE display_name TEXT,
  ADD ATTRIBUTE category TEXT,
  ADD ATTRIBUTE city TEXT,
  ADD ATTRIBUTE confidence DOUBLE PRECISION,
  ADD ATTRIBUTE country TEXT,
  ADD ATTRIBUTE country_code TEXT,
  ADD ATTRIBUTE distance_m DOUBLE PRECISION,
  ADD ATTRIBUTE full_address TEXT,
  ADD ATTRIBUTE house_number TEXT,
  ADD ATTRIBUTE interpolated BOOLEAN,
  ADD ATTRIBUTE name TEXT,
  ADD ATTRIBUTE osm_id BIGINT,
  ADD ATTRIBUTE osm_type TEXT,
  ADD ATTRIBUTE postcode TEXT,
  ADD ATTRIBUTE score DOUBLE PRECISION,
  ADD ATTRIBUTE source TEXT,
  ADD ATTRIBUTE state TEXT,
  ADD ATTRIBUTE street TEXT,
  ADD ATTRIBUTE subcategory TEXT,
  ADD ATTRIBUTE tags JSONB,
  ADD ATTRIBUTE wikipedia TEXT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_geocoding_feature_property(
  display_name TEXT,
  category TEXT DEFAULT NULL,
  city TEXT DEFAULT NULL,
  confidence DOUBLE PRECISION DEFAULT NULL,
  country TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  distance_m DOUBLE PRECISION DEFAULT NULL,
  full_address TEXT DEFAULT NULL,
  house_number TEXT DEFAULT NULL,
  interpolated BOOLEAN DEFAULT NULL,
  name TEXT DEFAULT NULL,
  osm_id BIGINT DEFAULT NULL,
  osm_type TEXT DEFAULT NULL,
  postcode TEXT DEFAULT NULL,
  score DOUBLE PRECISION DEFAULT NULL,
  source TEXT DEFAULT NULL,
  state TEXT DEFAULT NULL,
  street TEXT DEFAULT NULL,
  subcategory TEXT DEFAULT NULL,
  tags JSONB DEFAULT NULL,
  wikipedia TEXT DEFAULT NULL
)
RETURNS plaza_geocode.geocoding_feature_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    display_name,
    category,
    city,
    confidence,
    country,
    country_code,
    distance_m,
    full_address,
    house_number,
    interpolated,
    name,
    osm_id,
    osm_type,
    postcode,
    score,
    source,
    state,
    street,
    subcategory,
    tags,
    wikipedia
  )::plaza_geocode.geocoding_feature_property;
$$;

ALTER TYPE plaza_geocode.reverse_geocode_result
  ADD ATTRIBUTE features plaza_geocode.geocoding_feature[],
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_reverse_geocode_result(
  features plaza_geocode.geocoding_feature[], type TEXT
)
RETURNS plaza_geocode.reverse_geocode_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, type)::plaza_geocode.reverse_geocode_result;
$$;

ALTER TYPE plaza_geocode.geocode_batch_response
  ADD ATTRIBUTE count BIGINT,
  ADD ATTRIBUTE results plaza_geocode.geocode_result[];

CREATE OR REPLACE FUNCTION plaza_geocode.make_geocode_batch_response(
  count BIGINT, results plaza_geocode.geocode_result[]
)
RETURNS plaza_geocode.geocode_batch_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(count, results)::plaza_geocode.geocode_batch_response;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._autocomplete(
  q TEXT,
  format TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  focus plaza.point_geometry DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.autocomplete(
      q=q,
      format=not_given if format is None else format,
      country_code=not_given if country_code is None else country_code,
      focus=not_given if focus is None else GD["__plaza_context__"].strip_none(focus),
      lang=not_given if lang is None else lang,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.autocomplete(
  q TEXT,
  format TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  focus plaza.point_geometry DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL
)
RETURNS plaza_geocode.autocomplete_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.autocomplete_result,
      plaza_geocode._autocomplete(
        q, format, country_code, focus, lang, layer, "limit"
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._batch(addresses TEXT[])
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.geocode.with_raw_response.batch(
      addresses=addresses,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.batch(addresses TEXT[])
RETURNS plaza_geocode.geocode_batch_response
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.geocode_batch_response,
      plaza_geocode._batch(addresses)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._forward(
  q TEXT,
  format TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  focus plaza.point_geometry DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.forward(
      q=q,
      format=not_given if format is None else format,
      country_code=not_given if country_code is None else country_code,
      focus=not_given if focus is None else GD["__plaza_context__"].strip_none(focus),
      lang=not_given if lang is None else lang,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.forward(
  q TEXT,
  format TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  focus plaza.point_geometry DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL
)
RETURNS plaza_geocode.geocode_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.geocode_result,
      plaza_geocode._forward(
        q, format, country_code, focus, lang, layer, "limit"
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._reverse(
  geometry plaza.point_geometry,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.reverse(
      geometry=GD["__plaza_context__"].strip_none(geometry),
      format=not_given if format is None else format,
      lang=not_given if lang is None else lang,
      limit=not_given if limit is None else limit,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.reverse(
  geometry plaza.point_geometry,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_geocode.reverse_geocode_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.reverse_geocode_result,
      plaza_geocode._reverse(geometry, format, lang, "limit", radius)
    );
  END;
$$;