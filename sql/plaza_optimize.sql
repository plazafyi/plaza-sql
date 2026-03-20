ALTER TYPE plaza_optimize.optimize_completed_result
  ADD ATTRIBUTE features plaza_optimize.optimize_completed_result_feature[],
  ADD ATTRIBUTE optimization TEXT,
  ADD ATTRIBUTE roundtrip BOOLEAN,
  ADD ATTRIBUTE total_cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_completed_result(
  features plaza_optimize.optimize_completed_result_feature[],
  optimization TEXT,
  roundtrip BOOLEAN,
  total_cost_s DOUBLE PRECISION,
  type TEXT
)
RETURNS plaza_optimize.optimize_completed_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    features, optimization, roundtrip, total_cost_s, type
  )::plaza_optimize.optimize_completed_result;
$$;

ALTER TYPE plaza_optimize.optimize_completed_result_feature
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_optimize.optimize_completed_result_feature_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_completed_result_feature(
  geometry plaza.geo_json_geometry,
  properties plaza_optimize.optimize_completed_result_feature_property,
  type TEXT
)
RETURNS plaza_optimize.optimize_completed_result_feature
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, type
  )::plaza_optimize.optimize_completed_result_feature;
$$;

ALTER TYPE plaza_optimize.optimize_completed_result_feature_property
  ADD ATTRIBUTE cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE cumulative_cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE waypoint_index BIGINT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_completed_result_feature_property(
  cost_s DOUBLE PRECISION,
  cumulative_cost_s DOUBLE PRECISION,
  waypoint_index BIGINT
)
RETURNS plaza_optimize.optimize_completed_result_feature_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    cost_s, cumulative_cost_s, waypoint_index
  )::plaza_optimize.optimize_completed_result_feature_property;
$$;

ALTER TYPE plaza_optimize.optimize_job_status
  ADD ATTRIBUTE status TEXT,
  ADD ATTRIBUTE result plaza_optimize.optimize_completed_result;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_job_status(
  status TEXT, result plaza_optimize.optimize_completed_result DEFAULT NULL
)
RETURNS plaza_optimize.optimize_job_status
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(status, result)::plaza_optimize.optimize_job_status;
$$;

ALTER TYPE plaza_optimize.optimize_processing_result
  ADD ATTRIBUTE job_id TEXT, ADD ATTRIBUTE status TEXT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_processing_result(
  job_id TEXT, status TEXT
)
RETURNS plaza_optimize.optimize_processing_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(job_id, status)::plaza_optimize.optimize_processing_result;
$$;

ALTER TYPE plaza_optimize.optimize_request
  ADD ATTRIBUTE waypoints plaza_optimize.optimize_request_waypoint[],
  ADD ATTRIBUTE mode TEXT,
  ADD ATTRIBUTE roundtrip BOOLEAN;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_request(
  waypoints plaza_optimize.optimize_request_waypoint[],
  mode TEXT DEFAULT NULL,
  roundtrip BOOLEAN DEFAULT NULL
)
RETURNS plaza_optimize.optimize_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(waypoints, mode, roundtrip)::plaza_optimize.optimize_request;
$$;

ALTER TYPE plaza_optimize.optimize_request_waypoint
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_request_waypoint(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_optimize.optimize_request_waypoint
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_optimize.optimize_request_waypoint;
$$;

ALTER TYPE plaza_optimize.optimize_result
  ADD ATTRIBUTE features plaza_optimize.optimize_result_feature[],
  ADD ATTRIBUTE optimization TEXT,
  ADD ATTRIBUTE roundtrip BOOLEAN,
  ADD ATTRIBUTE total_cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE job_id TEXT,
  ADD ATTRIBUTE status TEXT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_result(
  features plaza_optimize.optimize_result_feature[] DEFAULT NULL,
  optimization TEXT DEFAULT NULL,
  roundtrip BOOLEAN DEFAULT NULL,
  total_cost_s DOUBLE PRECISION DEFAULT NULL,
  type TEXT DEFAULT NULL,
  job_id TEXT DEFAULT NULL,
  status TEXT DEFAULT NULL
)
RETURNS plaza_optimize.optimize_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    features, optimization, roundtrip, total_cost_s, type, job_id, status
  )::plaza_optimize.optimize_result;
$$;

ALTER TYPE plaza_optimize.optimize_result_feature
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_optimize.optimize_result_feature_property,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_result_feature(
  geometry plaza.geo_json_geometry,
  properties plaza_optimize.optimize_result_feature_property,
  type TEXT
)
RETURNS plaza_optimize.optimize_result_feature
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, type
  )::plaza_optimize.optimize_result_feature;
$$;

ALTER TYPE plaza_optimize.optimize_result_feature_property
  ADD ATTRIBUTE cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE cumulative_cost_s DOUBLE PRECISION,
  ADD ATTRIBUTE waypoint_index BIGINT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_result_feature_property(
  cost_s DOUBLE PRECISION,
  cumulative_cost_s DOUBLE PRECISION,
  waypoint_index BIGINT
)
RETURNS plaza_optimize.optimize_result_feature_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    cost_s, cumulative_cost_s, waypoint_index
  )::plaza_optimize.optimize_result_feature_property;
$$;

ALTER TYPE plaza_optimize.create_params_waypoint
  ADD ATTRIBUTE lat DOUBLE PRECISION, ADD ATTRIBUTE lng DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION plaza_optimize.make_create_params_waypoint(
  lat DOUBLE PRECISION, lng DOUBLE PRECISION
)
RETURNS plaza_optimize.create_params_waypoint
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(lat, lng)::plaza_optimize.create_params_waypoint;
$$;

CREATE OR REPLACE FUNCTION plaza_optimize._create(
  waypoints plaza_optimize.create_params_waypoint[],
  mode TEXT DEFAULT NULL,
  roundtrip BOOLEAN DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.optimize.with_raw_response.create(
      waypoints=GD["__plaza_context__"].strip_none(waypoints),
      mode=not_given if mode is None else mode,
      roundtrip=not_given if roundtrip is None else roundtrip,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_optimize.create(
  waypoints plaza_optimize.create_params_waypoint[],
  mode TEXT DEFAULT NULL,
  roundtrip BOOLEAN DEFAULT NULL
)
RETURNS plaza_optimize.optimize_result
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_optimize.optimize_result,
      plaza_optimize._create(waypoints, mode, roundtrip)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_optimize._retrieve(job_id TEXT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.optimize.with_raw_response.retrieve(
      job_id=job_id,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_optimize.retrieve(job_id TEXT)
RETURNS plaza_optimize.optimize_job_status
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza_optimize.optimize_job_status, plaza_optimize._retrieve(job_id)
    );
  END;
$$;