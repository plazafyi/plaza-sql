SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_map_match.match(
  trace := plaza.make_geo_json_geometry(
    coordinates := ARRAY[
      $$
      0
      $$::JSONB
    ],
    type := 'Point'
  )
);