ALTER TYPE plaza_datasets.dataset
  ADD ATTRIBUTE id TEXT,
  ADD ATTRIBUTE inserted_at TIMESTAMP,
  ADD ATTRIBUTE name TEXT,
  ADD ATTRIBUTE scope TEXT,
  ADD ATTRIBUTE slug TEXT,
  ADD ATTRIBUTE status TEXT,
  ADD ATTRIBUTE updated_at TIMESTAMP,
  ADD ATTRIBUTE address_count BIGINT,
  ADD ATTRIBUTE attribution TEXT,
  ADD ATTRIBUTE description TEXT,
  ADD ATTRIBUTE edge_count BIGINT,
  ADD ATTRIBUTE error_message TEXT,
  ADD ATTRIBUTE feature_count BIGINT,
  ADD ATTRIBUTE license TEXT,
  ADD ATTRIBUTE schema_definition JSONB,
  ADD ATTRIBUTE source_format TEXT,
  ADD ATTRIBUTE source_url TEXT,
  ADD ATTRIBUTE storage_bytes BIGINT,
  ADD ATTRIBUTE strict_mode BOOLEAN;

CREATE OR REPLACE FUNCTION plaza_datasets.make_dataset(
  id TEXT,
  inserted_at TIMESTAMP,
  name TEXT,
  scope TEXT,
  slug TEXT,
  status TEXT,
  updated_at TIMESTAMP,
  address_count BIGINT DEFAULT NULL,
  attribution TEXT DEFAULT NULL,
  description TEXT DEFAULT NULL,
  edge_count BIGINT DEFAULT NULL,
  error_message TEXT DEFAULT NULL,
  feature_count BIGINT DEFAULT NULL,
  license TEXT DEFAULT NULL,
  schema_definition JSONB DEFAULT NULL,
  source_format TEXT DEFAULT NULL,
  source_url TEXT DEFAULT NULL,
  storage_bytes BIGINT DEFAULT NULL,
  strict_mode BOOLEAN DEFAULT NULL
)
RETURNS plaza_datasets.dataset
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    id,
    inserted_at,
    name,
    scope,
    slug,
    status,
    updated_at,
    address_count,
    attribution,
    description,
    edge_count,
    error_message,
    feature_count,
    license,
    schema_definition,
    source_format,
    source_url,
    storage_bytes,
    strict_mode
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
  source_url TEXT DEFAULT NULL,
  strict_mode BOOLEAN DEFAULT NULL
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
      strict_mode=not_given if strict_mode is None else strict_mode,
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
  source_url TEXT DEFAULT NULL,
  strict_mode BOOLEAN DEFAULT NULL
)
RETURNS plaza_datasets.dataset
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_datasets.dataset,
      plaza_datasets._create(
        name, slug, attribution, description, license, source_url, strict_mode
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

CREATE OR REPLACE FUNCTION plaza_datasets._list(scope TEXT DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.datasets.with_raw_response.list(
      scope=not_given if scope is None else scope,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_datasets.list(scope TEXT DEFAULT NULL)
RETURNS plaza_datasets.dataset_list
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_datasets.dataset_list, plaza_datasets._list(scope)
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