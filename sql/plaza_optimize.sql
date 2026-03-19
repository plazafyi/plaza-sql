ALTER TYPE plaza_optimize.optimize_completed_result
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_optimize.optimize_completed_result_property,
  ADD ATTRIBUTE status TEXT,
  ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_completed_result(
  geometry plaza.geo_json_geometry,
  properties plaza_optimize.optimize_completed_result_property,
  status TEXT,
  type TEXT
)
RETURNS plaza_optimize.optimize_completed_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    geometry, properties, status, type
  )::plaza_optimize.optimize_completed_result;
$$;

ALTER TYPE plaza_optimize.optimize_completed_result_property
  ADD ATTRIBUTE distance DOUBLE PRECISION,
  ADD ATTRIBUTE duration DOUBLE PRECISION,
  ADD ATTRIBUTE waypoint_order BIGINT[];

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_completed_result_property(
  distance DOUBLE PRECISION DEFAULT NULL,
  duration DOUBLE PRECISION DEFAULT NULL,
  waypoint_order BIGINT[] DEFAULT NULL
)
RETURNS plaza_optimize.optimize_completed_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    distance, duration, waypoint_order
  )::plaza_optimize.optimize_completed_result_property;
$$;

ALTER TYPE plaza_optimize.optimize_job_status
  ADD ATTRIBUTE status TEXT,
  ADD ATTRIBUTE error TEXT,
  ADD ATTRIBUTE result JSONB;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_job_status(
  status TEXT, error TEXT DEFAULT NULL, result JSONB DEFAULT NULL
)
RETURNS plaza_optimize.optimize_job_status
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(status, error, result)::plaza_optimize.optimize_job_status;
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
  ADD ATTRIBUTE waypoints plaza.geo_json_geometry,
  ADD ATTRIBUTE mode TEXT,
  ADD ATTRIBUTE roundtrip BOOLEAN;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_request(
  waypoints plaza.geo_json_geometry,
  mode TEXT DEFAULT NULL,
  roundtrip BOOLEAN DEFAULT NULL
)
RETURNS plaza_optimize.optimize_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(waypoints, mode, roundtrip)::plaza_optimize.optimize_request;
$$;

ALTER TYPE plaza_optimize.optimize_result
  ADD ATTRIBUTE status TEXT,
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties plaza_optimize.optimize_result_property,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE job_id TEXT;

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_result(
  status TEXT,
  geometry plaza.geo_json_geometry DEFAULT NULL,
  properties plaza_optimize.optimize_result_property DEFAULT NULL,
  type TEXT DEFAULT NULL,
  job_id TEXT DEFAULT NULL
)
RETURNS plaza_optimize.optimize_result
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    status, geometry, properties, type, job_id
  )::plaza_optimize.optimize_result;
$$;

ALTER TYPE plaza_optimize.optimize_result_property
  ADD ATTRIBUTE distance DOUBLE PRECISION,
  ADD ATTRIBUTE duration DOUBLE PRECISION,
  ADD ATTRIBUTE waypoint_order BIGINT[];

CREATE OR REPLACE FUNCTION plaza_optimize.make_optimize_result_property(
  distance DOUBLE PRECISION DEFAULT NULL,
  duration DOUBLE PRECISION DEFAULT NULL,
  waypoint_order BIGINT[] DEFAULT NULL
)
RETURNS plaza_optimize.optimize_result_property
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    distance, duration, waypoint_order
  )::plaza_optimize.optimize_result_property;
$$;

CREATE OR REPLACE FUNCTION plaza_optimize._create(
  waypoints plaza.geo_json_geometry,
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
  waypoints plaza.geo_json_geometry,
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