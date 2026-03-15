ALTER TYPE plaza_v1_datasets.dataset_response
  ADD ATTRIBUTE id TEXT,
  ADD ATTRIBUTE inserted_at TIMESTAMP,
  ADD ATTRIBUTE name TEXT,
  ADD ATTRIBUTE slug TEXT,
  ADD ATTRIBUTE updated_at TIMESTAMP,
  ADD ATTRIBUTE attribution TEXT,
  ADD ATTRIBUTE description TEXT,
  ADD ATTRIBUTE license TEXT,
  ADD ATTRIBUTE source_url TEXT;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.make_dataset_response(
  id TEXT,
  inserted_at TIMESTAMP,
  name TEXT,
  slug TEXT,
  updated_at TIMESTAMP,
  attribution TEXT DEFAULT NULL,
  description TEXT DEFAULT NULL,
  license TEXT DEFAULT NULL,
  source_url TEXT DEFAULT NULL
)
RETURNS plaza_v1_datasets.dataset_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    id,
    inserted_at,
    name,
    slug,
    updated_at,
    attribution,
    description,
    license,
    source_url
  )::plaza_v1_datasets.dataset_response;
$$;

ALTER TYPE plaza_v1_datasets.feature_collection
  ADD ATTRIBUTE features plaza_v1_elements.geo_json_feature[],
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE pagination plaza_v1_datasets.feature_collection_pagination;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.make_feature_collection(
  features plaza_v1_elements.geo_json_feature[],
  type TEXT,
  pagination plaza_v1_datasets.feature_collection_pagination DEFAULT NULL
)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, type, pagination)::plaza_v1_datasets.feature_collection;
$$;

ALTER TYPE plaza_v1_datasets.feature_collection_pagination
  ADD ATTRIBUTE has_more BOOLEAN,
  ADD ATTRIBUTE "limit" BIGINT,
  ADD ATTRIBUTE next_cursor TEXT,
  ADD ATTRIBUTE next_offset BIGINT;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.make_feature_collection_pagination(
  has_more BOOLEAN DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  next_cursor TEXT DEFAULT NULL,
  next_offset BIGINT DEFAULT NULL
)
RETURNS plaza_v1_datasets.feature_collection_pagination
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    has_more, "limit", next_cursor, next_offset
  )::plaza_v1_datasets.feature_collection_pagination;
$$;

ALTER TYPE plaza_v1_datasets.dataset_list_response
  ADD ATTRIBUTE datasets plaza_v1_datasets.dataset_response[];

CREATE OR REPLACE FUNCTION plaza_v1_datasets.make_dataset_list_response(
  datasets plaza_v1_datasets.dataset_response[]
)
RETURNS plaza_v1_datasets.dataset_list_response
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(datasets)::plaza_v1_datasets.dataset_list_response;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets._create(
  name TEXT,
  slug TEXT,
  attribution TEXT DEFAULT NULL,
  description TEXT DEFAULT NULL,
  license TEXT DEFAULT NULL,
  source_url TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.datasets.with_raw_response.create(
      name=name,
      slug=slug,
      attribution=not_given if attribution is None else attribution,
      description=not_given if description is None else description,
      license=not_given if license is None else license,
      source_url=not_given if source_url is None else source_url,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.create(
  name TEXT,
  slug TEXT,
  attribution TEXT DEFAULT NULL,
  description TEXT DEFAULT NULL,
  license TEXT DEFAULT NULL,
  source_url TEXT DEFAULT NULL
)
RETURNS plaza_v1_datasets.dataset_response
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.dataset_response,
      plaza_v1_datasets._create(
        name, slug, attribution, description, license, source_url
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets._retrieve(id TEXT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.v1.datasets.with_raw_response.retrieve(
      id=id,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.retrieve(id TEXT)
RETURNS plaza_v1_datasets.dataset_response
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.dataset_response, plaza_v1_datasets._retrieve(id)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets._list()
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.v1.datasets.with_raw_response.list()

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.list()
RETURNS plaza_v1_datasets.dataset_list_response
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.dataset_list_response, plaza_v1_datasets._list()
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets._delete(id TEXT)
RETURNS VOID
LANGUAGE plpython3u
AS $$
  GD["__plaza_context__"].client.v1.datasets.delete(
      id=id,
  )
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.delete(id TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    PERFORM plaza_v1_datasets._delete(id);
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets._query_features(
  id TEXT, cursor TEXT DEFAULT NULL, "limit" BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.v1.datasets.with_raw_response.query_features(
      id=id,
      cursor=not_given if cursor is None else cursor,
      limit=not_given if limit is None else limit,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_v1_datasets.query_features(
  id TEXT, cursor TEXT DEFAULT NULL, "limit" BIGINT DEFAULT NULL
)
RETURNS plaza_v1_datasets.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_v1_datasets.feature_collection,
      plaza_v1_datasets._query_features(id, cursor, "limit")
    );
  END;
$$;