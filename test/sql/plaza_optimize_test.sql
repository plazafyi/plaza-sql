SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_optimize.create(
  waypoints := ARRAY[
    plaza_optimize.make_create_params_waypoint(lat := 48.8566, lng := 2.3522),
    plaza_optimize.make_create_params_waypoint(lat := 48.8606, lng := 2.3376),
    plaza_optimize.make_create_params_waypoint(lat := 48.8584, lng := 2.2945)
  ]
);

SELECT *
FROM plaza_optimize.retrieve(job_id := 'job_id');