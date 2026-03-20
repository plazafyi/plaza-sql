ALTER TYPE plaza_datasets.dataset
  ADD ATTRIBUTE id TEXT,
  ADD ATTRIBUTE inserted_at TIMESTAMP,
  ADD ATTRIBUTE name TEXT,
  ADD ATTRIBUTE slug TEXT,
  ADD ATTRIBUTE updated_at TIMESTAMP,
  ADD ATTRIBUTE attribution TEXT,
  ADD ATTRIBUTE description TEXT,
  ADD ATTRIBUTE license TEXT,
  ADD ATTRIBUTE source_url TEXT;

CREATE OR REPLACE FUNCTION plaza_datasets.make_dataset(
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
RETURNS plaza_datasets.dataset
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
  )::plaza_datasets.dataset;
$$;

ALTER TYPE plaza_datasets.dataset_list
  ADD ATTRIBUTE datasets plaza_datasets.dataset[];

CREATE OR REPLACE FUNCTION plaza_datasets.make_dataset_list(
  datasets plaza_datasets.dataset[]
)
RETURNS plaza_datasets.dataset_list
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(datasets)::plaza_datasets.dataset_list;
$$;

CREATE OR REPLACE FUNCTION plaza_datasets._create(
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

  response = GD["__plaza_context__"].client.datasets.with_raw_response.create(
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

CREATE OR REPLACE FUNCTION plaza_datasets.create(
  name TEXT,
  slug TEXT,
  attribution TEXT DEFAULT NULL,
  description TEXT DEFAULT NULL,
  license TEXT DEFAULT NULL,
  source_url TEXT DEFAULT NULL
)
RETURNS plaza_datasets.dataset
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_datasets.dataset,
      plaza_datasets._create(
        name, slug, attribution, description, license, source_url
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_datasets._retrieve(id TEXT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.datasets.with_raw_response.retrieve(
      id=id,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_datasets.retrieve(id TEXT)
RETURNS plaza_datasets.dataset
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_datasets.dataset, plaza_datasets._retrieve(id)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_datasets._list()
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.datasets.with_raw_response.list()

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_datasets.list()
RETURNS plaza_datasets.dataset_list
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_datasets.dataset_list, plaza_datasets._list()
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_datasets._delete(id TEXT)
RETURNS VOID
LANGUAGE plpython3u
AS $$
  GD["__plaza_context__"].client.datasets.delete(
      id=id,
  )
$$;

CREATE OR REPLACE FUNCTION plaza_datasets.delete(id TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    PERFORM plaza_datasets._delete(id);
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_datasets._features(
  id TEXT,
  cursor TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.datasets.with_raw_response.features(
      id=id,
      cursor=not_given if cursor is None else cursor,
      limit=not_given if limit is None else limit,
      output_buffer=not_given if output_buffer is None else output_buffer,
      output_centroid=not_given if output_centroid is None else output_centroid,
      output_fields=not_given if output_fields is None else output_fields,
      output_geometry=not_given if output_geometry is None else output_geometry,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_simplify=not_given if output_simplify is None else output_simplify,
      output_sort=not_given if output_sort is None else output_sort,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_datasets.features(
  id TEXT,
  cursor TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  output_buffer DOUBLE PRECISION DEFAULT NULL,
  output_centroid BOOLEAN DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_geometry BOOLEAN DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_simplify DOUBLE PRECISION DEFAULT NULL,
  output_sort TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_datasets._features(
        id,
        cursor,
        "limit",
        output_buffer,
        output_centroid,
        output_fields,
        output_geometry,
        output_include,
        output_precision,
        output_simplify,
        output_sort
      )
    );
  END;
$$;