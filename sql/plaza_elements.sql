ALTER TYPE plaza_elements.batch_request
  ADD ATTRIBUTE elements plaza_elements.batch_request_element[];

CREATE OR REPLACE FUNCTION plaza_elements.make_batch_request(
  elements plaza_elements.batch_request_element[]
)
RETURNS plaza_elements.batch_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(elements)::plaza_elements.batch_request;
$$;

ALTER TYPE plaza_elements.batch_request_element
  ADD ATTRIBUTE id BIGINT, ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elements.make_batch_request_element(
  id BIGINT, type TEXT
)
RETURNS plaza_elements.batch_request_element
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(id, type)::plaza_elements.batch_request_element;
$$;

ALTER TYPE plaza_elements.batch_params_element
  ADD ATTRIBUTE id BIGINT, ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_elements.make_batch_params_element(
  id BIGINT, type TEXT
)
RETURNS plaza_elements.batch_params_element
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(id, type)::plaza_elements.batch_params_element;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._retrieve(type TEXT, id BIGINT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.elements.with_raw_response.retrieve(
      type=type,
      id=id,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.retrieve(type TEXT, id BIGINT)
RETURNS plaza.geo_json_feature
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.geo_json_feature, plaza_elements._retrieve(type, id)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._batch(
  elements plaza_elements.batch_params_element[]
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.elements.with_raw_response.batch(
      elements=GD["__plaza_context__"].strip_none(elements),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.batch(
  elements plaza_elements.batch_params_element[]
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection, plaza_elements._batch(elements)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._nearby(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "limit" BIGINT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elements.with_raw_response.nearby(
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

CREATE OR REPLACE FUNCTION plaza_elements.nearby(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  "limit" BIGINT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_elements._nearby(lat, lng, "limit", radius)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._query(
  bbox TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elements.with_raw_response.query(
      bbox=not_given if bbox is None else bbox,
      cursor=not_given if cursor is None else cursor,
      h3=not_given if h3 is None else h3,
      limit=not_given if limit is None else limit,
      type=not_given if type is None else type,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.query(
  bbox TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_elements._query(bbox, cursor, h3, "limit", type)
    );
  END;
$$;