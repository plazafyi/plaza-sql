SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_map_match.match(
  geometry := plaza.make_line_string_geometry(
    coordinates := ARRAY[
      ARRAY[2.3522, 48.8566], ARRAY[2.353, 48.857], ARRAY[2.354, 48.8575]
    ],
    type := 'LineString'
  )
);