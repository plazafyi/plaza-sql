SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_routing.isochrone(lat := 0, lng := 0, "time" := 0);

SELECT *
FROM plaza_routing.matrix(
  destinations := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  ),
  origins := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  )
);

SELECT *
FROM plaza_routing.nearest(lat := 0, lng := 0);

SELECT *
FROM plaza_routing.route(
  destination := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  ),
  origin := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  )
);