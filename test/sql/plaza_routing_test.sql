SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_routing.isochrone(lat := 0, lng := 0, "time" := 0);

SELECT *
FROM plaza_routing.isochrone_post(lat := 0, lng := 0, "time" := 0);

SELECT *
FROM plaza_routing.matrix(
  destinations := ARRAY[
    plaza_routing.make_matrix_params_destination(lat := 48.8584, lng := 2.2945)
  ],
  origins := ARRAY[
    plaza_routing.make_matrix_params_origin(lat := 48.8566, lng := 2.3522),
    plaza_routing.make_matrix_params_origin(lat := 48.8606, lng := 2.3376)
  ]
);

SELECT *
FROM plaza_routing.nearest(lat := 0, lng := 0);

SELECT *
FROM plaza_routing.nearest_post(lat := 0, lng := 0);

SELECT *
FROM plaza_routing.route(
  destination := plaza_routing.make_route_params_destination(
    lat := 48.8584, lng := 2.2945
  ),
  origin := plaza_routing.make_route_params_origin(
    lat := 48.8566, lng := 2.3522
  )
);