SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_elevation.batch(
  coordinates := ARRAY[
    plaza_elevation.make_batch_params_coordinate(lat := 48.8566, lng := 2.3522),
    plaza_elevation.make_batch_params_coordinate(lat := 45.764, lng := 4.8357)
  ]
);

SELECT *
FROM plaza_elevation.lookup();

SELECT *
FROM plaza_elevation.lookup_post();

SELECT *
FROM plaza_elevation.profile(
  coordinates := ARRAY[
    plaza_elevation.make_profile_params_coordinate(
      lat := 48.8566, lng := 2.3522
    ),
    plaza_elevation.make_profile_params_coordinate(lat := 48.858, lng := 2.34),
    plaza_elevation.make_profile_params_coordinate(
      lat := 48.8584, lng := 2.2945
    )
  ]
);