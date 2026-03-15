ALTER TYPE plaza_v1_geocode.geocode_autocomplete_response
  ADD ATTRIBUTE results plaza_v1_geocode.geocode_autocomplete_response_result[];

CREATE OR REPLACE FUNCTION plaza_v1_geocode.make_geocode_autocomplete_response(
  results plaza_v1_geocode.geocode_autocomplete_response_result[]
)
RETURNS plaza_v1_geocode.geocode_autocomplete_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(results)::plaza_v1_geocode.geocode_autocomplete_response;
$$;

ALTER TYPE plaza_v1_geocode.geocode_autocomplete_response_result
  ADD ATTRIBUTE display_name TEXT,
  ADD ATTRIBUTE lat DOUBLE PRECISION,
  ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_v1_geocode.make_geocode_autocomplete_response_result(
  display_name TEXT,
  lat DOUBLE PRECISION DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_v1_geocode.geocode_autocomplete_response_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    display_name, lat, lng
  )::plaza_v1_geocode.geocode_autocomplete_response_result;
$$;

ALTER TYPE plaza_v1_geocode.geocode_forward_response
  ADD ATTRIBUTE results plaza_v1_geocode.geocode_forward_response_result[],
  ADD ATTRIBUTE count BIGINT;

CREATE OR REPLACE FUNCTION plaza_v1_geocode.make_geocode_forward_response(
  results plaza_v1_geocode.geocode_forward_response_result[],
  count BIGINT DEFAULT NULL
)
RETURNS plaza_v1_geocode.geocode_forward_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(results, count)::plaza_v1_geocode.geocode_forward_response;
$$;

ALTER TYPE plaza_v1_geocode.geocode_forward_response_result
  ADD ATTRIBUTE display_name TEXT,
  ADD ATTRIBUTE lat DOUBLE PRECISION,
  ADD ATTRIBUTE lng DOUBLE PRECISION,
  ADD ATTRIBUTE osm_id BIGINT,
  ADD ATTRIBUTE osm_type TEXT,
  ADD ATTRIBUTE score DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_v1_geocode.make_geocode_forward_response_result(
  display_name TEXT,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  osm_id BIGINT DEFAULT NULL,
  osm_type TEXT DEFAULT NULL,
  score DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_v1_geocode.geocode_forward_response_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    display_name, lat, lng, osm_id, osm_type, score
  )::plaza_v1_geocode.geocode_forward_response_result;
$$;

ALTER TYPE plaza_v1_geocode.geocode_reverse_response
  ADD ATTRIBUTE address TEXT,
  ADD ATTRIBUTE distance DOUBLE PRECISION,
  ADD ATTRIBUTE lat DOUBLE PRECISION,
  ADD ATTRIBUTE lng DOUBLE PRECISION,
  ADD ATTRIBUTE osm_id BIGINT,
  ADD ATTRIBUTE osm_type TEXT;

CREATE OR REPLACE FUNCTION plaza_v1_geocode.make_geocode_reverse_response(
  address TEXT,
  distance DOUBLE PRECISION,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  osm_id BIGINT DEFAULT NULL,
  osm_type TEXT DEFAULT NULL
)
RETURNS plaza_v1_geocode.geocode_reverse_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    address, distance, lat, lng, osm_id, osm_type
  )::plaza_v1_geocode.geocode_reverse_response;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_geocode._autocomplete(
  q TEXT,
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.geocode.with_raw_response.autocomplete(
      q=q,
      lat=not_given if lat is None else lat,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_geocode.autocomplete(
  q TEXT,
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_v1_geocode.geocode_autocomplete_response
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_geocode.geocode_autocomplete_response,
      plaza_v1_geocode._autocomplete(q, lat, "limit", lng)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_geocode._forward(
  q TEXT,
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.geocode.with_raw_response.forward(
      q=q,
      lat=not_given if lat is None else lat,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_geocode.forward(
  q TEXT,
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS plaza_v1_geocode.geocode_forward_response
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_geocode.geocode_forward_response,
      plaza_v1_geocode._forward(q, lat, "limit", lng)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_geocode._reverse(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION, radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.geocode.with_raw_response.reverse(
      lat=lat,
      lng=lng,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_geocode.reverse(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION, radius BIGINT DEFAULT NULL
)
RETURNS plaza_v1_geocode.geocode_reverse_response
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_geocode.geocode_reverse_response,
      plaza_v1_geocode._reverse(lat, lng, radius)
    );
  END;
$$;