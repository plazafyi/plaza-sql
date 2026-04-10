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

CREATE SCHEMA IF NOT EXISTS plaza;

CREATE TYPE plaza.error AS ();
CREATE TYPE plaza.error_error AS ();
CREATE TYPE plaza.feature_collection AS ();
CREATE TYPE plaza.geo_json_feature AS ();
CREATE TYPE plaza.geometry AS ();
CREATE TYPE plaza.line_string_geometry AS ();
CREATE TYPE plaza.multi_line_string_geometry AS ();
CREATE TYPE plaza.multi_point_geometry AS ();
CREATE TYPE plaza.multi_polygon_geometry AS ();
CREATE TYPE plaza.point_geometry AS ();
CREATE TYPE plaza.polygon_geometry AS ();
CREATE TYPE plaza.validation_error AS ();
CREATE TYPE plaza.validation_error_error AS ();

CREATE SCHEMA IF NOT EXISTS plaza_features;

CREATE TYPE plaza_features.batch_request AS ();
CREATE TYPE plaza_features.batch_request_element AS ();
CREATE TYPE plaza_features.spatial_predicate AS ();
CREATE TYPE plaza_features.batch_params_element AS ();

CREATE SCHEMA IF NOT EXISTS plaza_datasets;

CREATE TYPE plaza_datasets.dataset AS ();
CREATE TYPE plaza_datasets.dataset_list AS ();

CREATE SCHEMA IF NOT EXISTS plaza_geocode;

CREATE TYPE plaza_geocode.autocomplete_request AS ();
CREATE TYPE plaza_geocode.autocomplete_result AS ();
CREATE TYPE plaza_geocode.geocode_forward_request AS ();
CREATE TYPE plaza_geocode.geocode_result AS ();
CREATE TYPE plaza_geocode.geocode_reverse_request AS ();
CREATE TYPE plaza_geocode.geocoding_feature AS ();
CREATE TYPE plaza_geocode.geocoding_feature_property AS ();
CREATE TYPE plaza_geocode.reverse_geocode_result AS ();
CREATE TYPE plaza_geocode.geocode_batch_response AS ();

CREATE SCHEMA IF NOT EXISTS plaza_search;

CREATE SCHEMA IF NOT EXISTS plaza_routing;

CREATE TYPE plaza_routing.isochrone_request AS ();
CREATE TYPE plaza_routing.matrix_request AS ();
CREATE TYPE plaza_routing.nearest_request AS ();
CREATE TYPE plaza_routing.nearest_result AS ();
CREATE TYPE plaza_routing.nearest_result_property AS ();
CREATE TYPE plaza_routing.route_request AS ();
CREATE TYPE plaza_routing.route_request_ev AS ();
CREATE TYPE plaza_routing.route_result AS ();
CREATE TYPE plaza_routing.route_result_property AS ();
CREATE TYPE plaza_routing.routing_isochrone_response AS ();
CREATE TYPE plaza_routing.route_params_ev AS ();

CREATE SCHEMA IF NOT EXISTS plaza_elevation;

CREATE TYPE plaza_elevation.elevation_lookup_request AS ();
CREATE TYPE plaza_elevation.elevation_lookup_request_geometry AS ();
CREATE TYPE plaza_elevation.elevation_lookup_result AS ();
CREATE TYPE plaza_elevation.elevation_lookup_result_property AS ();
CREATE TYPE plaza_elevation.elevation_profile_request AS ();
CREATE TYPE plaza_elevation.elevation_profile_result AS ();
CREATE TYPE plaza_elevation.elevation_profile_result_property AS ();
CREATE TYPE plaza_elevation.lookup_params_geometry AS ();

CREATE SCHEMA IF NOT EXISTS plaza_map_match;

CREATE TYPE plaza_map_match.map_match_request AS ();
CREATE TYPE plaza_map_match.map_match_result AS ();
CREATE TYPE plaza_map_match.map_match_result_feature AS ();
CREATE TYPE plaza_map_match.map_match_result_feature_property AS ();

CREATE SCHEMA IF NOT EXISTS plaza_optimize;

CREATE TYPE plaza_optimize.optimize_completed_result AS ();
CREATE TYPE plaza_optimize.optimize_completed_result_feature AS ();
CREATE TYPE plaza_optimize.optimize_completed_result_feature_property AS ();
CREATE TYPE plaza_optimize.optimize_job_status AS ();
CREATE TYPE plaza_optimize.optimize_processing_result AS ();
CREATE TYPE plaza_optimize.optimize_request AS ();
CREATE TYPE plaza_optimize.optimize_result AS ();
CREATE TYPE plaza_optimize.optimize_result_feature AS ();
CREATE TYPE plaza_optimize.optimize_result_feature_property AS ();

CREATE SCHEMA IF NOT EXISTS plaza_query;

CREATE TYPE plaza_query.plazaql_query AS ();

CREATE SCHEMA IF NOT EXISTS plaza_tiles;