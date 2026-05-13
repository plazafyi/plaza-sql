SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_elevation.lookup(
  geometry := plaza_elevation.make_lookup_params_geometry(
    coordinates := ARRAY[
      $$
      2.3522
      $$::JSONB,
      $$
      48.8566
      $$::JSONB
    ],
    type := 'Point'
  )
);

SELECT *
FROM plaza_elevation.profile(
  geometry := plaza.make_line_string_geometry(
    coordinates := ARRAY[
      ARRAY[2.3522, 48.8566], ARRAY[2.34, 48.858], ARRAY[2.2945, 48.8584]
    ],
    type := 'LineString'
  )
);