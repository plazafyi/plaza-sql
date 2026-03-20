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

CREATE OR REPLACE FUNCTION plaza_elements._lookup()
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.elements.with_raw_response.lookup()

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.lookup()
RETURNS plaza.geo_json_feature
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.geo_json_feature, plaza_elements._lookup()
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._nearby(
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elements.with_raw_response.nearby(
      lat=not_given if lat is None else lat,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
      near=not_given if near is None else near,
      output_buffer=not_given if output_buffer is None else output_buffer,
      output_centroid=not_given if output_centroid is None else output_centroid,
      output_fields=not_given if output_fields is None else output_fields,
      output_geometry=not_given if output_geometry is None else output_geometry,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_simplify=not_given if output_simplify is None else output_simplify,
      output_sort=not_given if output_sort is None else output_sort,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.nearby(
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
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
      plaza_elements._nearby(
        lat,
        "limit",
        lng,
        near,
        output_buffer,
        output_centroid,
        output_fields,
        output_geometry,
        output_include,
        output_precision,
        output_simplify,
        output_sort,
        radius
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._nearby_post(
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elements.with_raw_response.nearby_post(
      lat=not_given if lat is None else lat,
      limit=not_given if limit is None else limit,
      lng=not_given if lng is None else lng,
      near=not_given if near is None else near,
      output_buffer=not_given if output_buffer is None else output_buffer,
      output_centroid=not_given if output_centroid is None else output_centroid,
      output_fields=not_given if output_fields is None else output_fields,
      output_geometry=not_given if output_geometry is None else output_geometry,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_simplify=not_given if output_simplify is None else output_simplify,
      output_sort=not_given if output_sort is None else output_sort,
      radius=not_given if radius is None else radius,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.nearby_post(
  lat DOUBLE PRECISION DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  lng DOUBLE PRECISION DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
  radius BIGINT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_elements._nearby_post(
        lat,
        "limit",
        lng,
        near,
        output_buffer,
        output_centroid,
        output_fields,
        output_geometry,
        output_include,
        output_precision,
        output_simplify,
        output_sort,
        radius
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._query(
  bbox TEXT DEFAULT NULL,
  contains TEXT DEFAULT NULL,
  crosses TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  intersects TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL,
  touches TEXT DEFAULT NULL,
  type TEXT DEFAULT NULL,
  within TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elements.with_raw_response.query(
      bbox=not_given if bbox is None else bbox,
      contains=not_given if contains is None else contains,
      crosses=not_given if crosses is None else crosses,
      cursor=not_given if cursor is None else cursor,
      format=not_given if format is None else format,
      h3=not_given if h3 is None else h3,
      intersects=not_given if intersects is None else intersects,
      limit=not_given if limit is None else limit,
      near=not_given if near is None else near,
      output_buffer=not_given if output_buffer is None else output_buffer,
      output_centroid=not_given if output_centroid is None else output_centroid,
      output_fields=not_given if output_fields is None else output_fields,
      output_geometry=not_given if output_geometry is None else output_geometry,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_simplify=not_given if output_simplify is None else output_simplify,
      output_sort=not_given if output_sort is None else output_sort,
      radius=not_given if radius is None else radius,
      touches=not_given if touches is None else touches,
      type=not_given if type is None else type,
      within=not_given if within is None else within,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.query(
  bbox TEXT DEFAULT NULL,
  contains TEXT DEFAULT NULL,
  crosses TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  intersects TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL,
  touches TEXT DEFAULT NULL,
  type TEXT DEFAULT NULL,
  within TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_elements._query(
        bbox,
        contains,
        crosses,
        cursor,
        format,
        h3,
        intersects,
        "limit",
        near,
        output_buffer,
        output_centroid,
        output_fields,
        output_geometry,
        output_include,
        output_precision,
        output_simplify,
        output_sort,
        radius,
        touches,
        type,
        within
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_elements._query_post(
  bbox TEXT DEFAULT NULL,
  contains TEXT DEFAULT NULL,
  crosses TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  intersects TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL,
  touches TEXT DEFAULT NULL,
  type TEXT DEFAULT NULL,
  within TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.elements.with_raw_response.query_post(
      bbox=not_given if bbox is None else bbox,
      contains=not_given if contains is None else contains,
      crosses=not_given if crosses is None else crosses,
      cursor=not_given if cursor is None else cursor,
      format=not_given if format is None else format,
      h3=not_given if h3 is None else h3,
      intersects=not_given if intersects is None else intersects,
      limit=not_given if limit is None else limit,
      near=not_given if near is None else near,
      output_buffer=not_given if output_buffer is None else output_buffer,
      output_centroid=not_given if output_centroid is None else output_centroid,
      output_fields=not_given if output_fields is None else output_fields,
      output_geometry=not_given if output_geometry is None else output_geometry,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_simplify=not_given if output_simplify is None else output_simplify,
      output_sort=not_given if output_sort is None else output_sort,
      radius=not_given if radius is None else radius,
      touches=not_given if touches is None else touches,
      type=not_given if type is None else type,
      within=not_given if within is None else within,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_elements.query_post(
  bbox TEXT DEFAULT NULL,
  contains TEXT DEFAULT NULL,
  crosses TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  intersects TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  near TEXT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL,
  touches TEXT DEFAULT NULL,
  type TEXT DEFAULT NULL,
  within TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_elements._query_post(
        bbox,
        contains,
        crosses,
        cursor,
        format,
        h3,
        intersects,
        "limit",
        near,
        output_buffer,
        output_centroid,
        output_fields,
        output_geometry,
        output_include,
        output_precision,
        output_simplify,
        output_sort,
        radius,
        touches,
        type,
        within
      )
    );
  END;
$$;