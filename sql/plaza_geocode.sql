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

ALTER TYPE plaza_geocode.geocoding_feature
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_geocode.geocoding_feature_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_geocode.make_geocoding_feature(
  geometry plaza.geo_json_geometry,
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
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.autocomplete(
      q=q,
      country_code=not_given if country_code is None else country_code,
      format=not_given if format is None else format,
      lang=not_given if lang is None else lang,
      lat=not_given if lat is None else lat,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.autocomplete(
  q TEXT,
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_geocode.autocomplete_result
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.autocomplete_result,
      plaza_geocode._autocomplete(
        q, country_code, format, lang, lat, layer, "limit", lng
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._autocomplete_post(
  q TEXT,
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.autocomplete_post(
      q=q,
      country_code=not_given if country_code is None else country_code,
      format=not_given if format is None else format,
      lang=not_given if lang is None else lang,
      lat=not_given if lat is None else lat,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.autocomplete_post(
  q TEXT,
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_geocode.autocomplete_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.autocomplete_result,
      plaza_geocode._autocomplete_post(
        q, country_code, format, lang, lat, layer, "limit", lng
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
  bbox TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.forward(
      q=q,
      bbox=not_given if bbox is None else bbox,
      country_code=not_given if country_code is None else country_code,
      format=not_given if format is None else format,
      lang=not_given if lang is None else lang,
      lat=not_given if lat is None else lat,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.forward(
  q TEXT,
  bbox TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_geocode.geocode_result
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.geocode_result,
      plaza_geocode._forward(
        q, bbox, country_code, format, lang, lat, layer, "limit", lng
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._forward_post(
  q TEXT,
  bbox TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.forward_post(
      q=q,
      bbox=not_given if bbox is None else bbox,
      country_code=not_given if country_code is None else country_code,
      format=not_given if format is None else format,
      lang=not_given if lang is None else lang,
      lat=not_given if lat is None else lat,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.forward_post(
  q TEXT,
  bbox TEXT DEFAULT NULL,
  country_code TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_geocode.geocode_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.geocode_result,
      plaza_geocode._forward_post(
        q, bbox, country_code, format, lang, lat, layer, "limit", lng
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._reverse(
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.reverse(
      format=not_given if format is None else format,
      lang=not_given if lang is None else lang,
      lat=not_given if lat is None else lat,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
      near=not_given if near is None else near,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.reverse(
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS plaza_geocode.reverse_geocode_result
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.reverse_geocode_result,
      plaza_geocode._reverse(
        format, lang, lat, layer, "limit", lng, near, radius
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_geocode._reverse_post(
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.geocode.with_raw_response.reverse_post(
      format=not_given if format is None else format,
      lang=not_given if lang is None else lang,
      lat=not_given if lat is None else lat,
      layer=not_given if layer is None else layer,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
      near=not_given if near is None else near,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_geocode.reverse_post(
  format TEXT DEFAULT NULL,
  lang TEXT DEFAULT NULL,
  lat DOUBLE PRECISION DEFAULT NULL,
  layer TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS plaza_geocode.reverse_geocode_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_geocode.reverse_geocode_result,
      plaza_geocode._reverse_post(
        format, lang, lat, layer, "limit", lng, near, radius
      )
    );
  END;
$$;