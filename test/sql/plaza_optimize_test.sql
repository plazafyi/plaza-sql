SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_optimize.create(
  waypoints := plaza.make_multi_point_geometry(
    coordinates := ARRAY[
      ARRAY[2.3522, 48.8566], ARRAY[2.3376, 48.8606], ARRAY[2.2945, 48.8584]
    ],
    type := 'MultiPoint'
  )
);

SELECT *
FROM plaza_optimize.retrieve(job_id := 'job_id');