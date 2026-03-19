SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_optimize.create(
  waypoints := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  )
);

SELECT *
FROM plaza_optimize.retrieve(job_id := 'job_id');