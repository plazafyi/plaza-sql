SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_elevation.batch(
  geometry := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  )
);

SELECT *
FROM plaza_elevation.lookup();

SELECT *
FROM plaza_elevation.profile(
  geometry := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  )
);