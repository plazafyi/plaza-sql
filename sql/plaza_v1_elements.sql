ALTER TYPE plaza_v1_elements.geo_json_feature
  ADD ATTRIBUTE geometry plaza_v1_elements.geo_json_geometry,
  ADD ATTRIBUTE properties JSONB,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE id TEXT,
  ADD ATTRIBUTE osm_id BIGINT;

CREATE OR REPLACE FUNCTION plaza_v1_elements.make_geo_json_feature(
  geometry plaza_v1_elements.geo_json_geometry,
  properties JSONB,
  type TEXT,
  id TEXT DEFAULT NULL,
  osm_id BIGINT DEFAULT NULL
)
RETURNS plaza_v1_elements.geo_json_feature
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, type, id, osm_id
  )::plaza_v1_elements.geo_json_feature;
$$;

ALTER TYPE plaza_v1_elements.geo_json_geometry
  ADD ATTRIBUTE coordinates JSONB[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_v1_elements.make_geo_json_geometry(
  coordinates JSONB[], type TEXT
)
RETURNS plaza_v1_elements.geo_json_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza_v1_elements.geo_json_geometry;
$$;

ALTER TYPE plaza_v1_elements.fetch_batch_params_element
  ADD ATTRIBUTE id BIGINT, ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_v1_elements.make_fetch_batch_params_element(
  id BIGINT, type TEXT
)
RETURNS plaza_v1_elements.fetch_batch_params_element
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(id, type)::plaza_v1_elements.fetch_batch_params_element;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_elements._retrieve(type TEXT, id BIGINT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.v1.elements.with_raw_response.retrieve(
      type=type,
      id=id,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_elements.retrieve(type TEXT, id BIGINT)
RETURNS plaza_v1_elements.geo_json_feature
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_elements.geo_json_feature,
      plaza_v1_elements._retrieve(type, id)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_elements._fetch_batch(
  elements plaza_v1_elements.fetch_batch_params_element[]
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.v1.elements.with_raw_response.fetch_batch(
      elements=GD["__plaza_context__"].strip_none(elements),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_elements.fetch_batch(
  elements plaza_v1_elements.fetch_batch_params_element[]
)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.feature_collection,
      plaza_v1_elements._fetch_batch(elements)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_elements._query(
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

  response = GD["__plaza_context__"].client.v1.elements.with_raw_response.query(
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

CREATE OR REPLACE FUNCTION plaza_v1_elements.query(
  bbox TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.feature_collection,
      plaza_v1_elements._query(bbox, cursor, h3, "limit", type)
    );
  END;
$$;