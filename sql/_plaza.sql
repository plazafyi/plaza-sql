-- A file that declares all schemas and types upfront so that their definitions don't
-- have to be topologically sorted in other files. It also creates some internal utility functions.

CREATE SCHEMA IF NOT EXISTS plaza_internal;
REVOKE ALL ON SCHEMA plaza_internal FROM PUBLIC;

CREATE OR REPLACE FUNCTION plaza_internal.ensure_empty_type(
  p_schema TEXT,
  p_type TEXT
)
RETURNS void
LANGUAGE plpgsql
AS $$
  DECLARE
    attr RECORD;
  BEGIN
    -- Create an empty type if it doesn't exist from a previous extension version.
    IF NOT EXISTS (
      SELECT 1
      FROM pg_type t
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE t.typname = p_type
        AND n.nspname = p_schema
    ) THEN
      EXECUTE format(
        'CREATE TYPE %I.%I AS ();',
        p_schema,
        p_type
      );
      -- Already empty, nothing to drop.
      RETURN;
    END IF;

    -- Drop all existing attributes from the previous extension version so we can readd them.
    FOR attr IN
      SELECT a.attname
      FROM pg_attribute a
      JOIN pg_type t ON t.typrelid = a.attrelid
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE t.typname = p_type
        AND n.nspname = p_schema
        AND a.attnum > 0
        AND NOT a.attisdropped
      ORDER BY a.attnum DESC
    LOOP
      EXECUTE format(
        'ALTER TYPE %I.%I DROP ATTRIBUTE %I;',
        p_schema,
        p_type,
        attr.attname
      );
    END LOOP;
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_internal.ensure_context()
RETURNS void
LANGUAGE plpython3u
AS $$
  from types import SimpleNamespace
  from plaza import Plaza

  if "__plaza_context__" in GD:
      # The context was already created.
      return

  client_options = {}
  try:
      value = plpy.execute("SELECT current_setting('plaza.base_url') AS value")[0]['value']
      client_options["base_url"] = value
  except Exception:
      # This configuration parameter was not set, but it's optional so ignore the exception.
      pass
  try:
      value = plpy.execute("SELECT current_setting('plaza.environment') AS value")[0]['value']
      client_options["environment"] = value
  except Exception:
      # This configuration parameter was not set, but it's optional so ignore the exception.
      pass
  try:
      value = plpy.execute("SELECT current_setting('plaza.api_key') AS value")[0]['value']
      client_options["api_key"] = value
  except Exception:
      plpy.warning(
        "Required DB config parameter 'plaza.api_key' is not set",
        hint="ALTER DATABASE my_database SET plaza.api_key = ...;"
      )

  def strip_none(value):
      if isinstance(value, dict):
          return {
              k: strip_none(v)
              for k, v in value.items()
              if v is not None
          }
      elif isinstance(value, list):
          return [strip_none(v) for v in value]
      else:
          return value

  GD["__plaza_context__"] = SimpleNamespace(
      client=Plaza(**client_options),
      strip_none=strip_none,
  )
$$;

CREATE TYPE plaza_internal.page AS (
  data JSONB,
  next_request_options JSONB
);

CREATE SCHEMA IF NOT EXISTS plaza_v1;

CREATE TYPE plaza_v1.v1_calculate_distance_matrix_response AS ();
CREATE TYPE plaza_v1.v1_calculate_route_response AS ();
CREATE TYPE plaza_v1.v1_calculate_route_response_property AS ();
CREATE TYPE plaza_v1.v1_execute_sparql_response AS ();
CREATE TYPE plaza_v1.v1_snap_to_nearest_response AS ();
CREATE TYPE plaza_v1.calculate_distance_matrix_params_destination AS ();
CREATE TYPE plaza_v1.calculate_distance_matrix_params_origin AS ();
CREATE TYPE plaza_v1.calculate_route_params_destination AS ();
CREATE TYPE plaza_v1.calculate_route_params_origin AS ();

CREATE SCHEMA IF NOT EXISTS plaza_v1_datasets;

CREATE TYPE plaza_v1_datasets.dataset_response AS ();
CREATE TYPE plaza_v1_datasets.feature_collection AS ();
CREATE TYPE plaza_v1_datasets.feature_collection_pagination AS ();
CREATE TYPE plaza_v1_datasets.dataset_list_response AS ();

CREATE SCHEMA IF NOT EXISTS plaza_v1_elements;

CREATE TYPE plaza_v1_elements.geo_json_feature AS ();
CREATE TYPE plaza_v1_elements.geo_json_geometry AS ();
CREATE TYPE plaza_v1_elements.fetch_batch_params_element AS ();

CREATE SCHEMA IF NOT EXISTS plaza_v1_geocode;

CREATE TYPE plaza_v1_geocode.geocode_autocomplete_response AS ();
CREATE TYPE plaza_v1_geocode.geocode_autocomplete_response_result AS ();
CREATE TYPE plaza_v1_geocode.geocode_forward_response AS ();
CREATE TYPE plaza_v1_geocode.geocode_forward_response_result AS ();
CREATE TYPE plaza_v1_geocode.geocode_reverse_response AS ();