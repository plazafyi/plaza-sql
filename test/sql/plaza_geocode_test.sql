SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_geocode.autocomplete(q := '221B Bak');

SELECT *
FROM plaza_geocode.batch(addresses := ARRAY['string']);

SELECT *
FROM plaza_geocode.forward(q := '221B Baker Street, London');

SELECT *
FROM plaza_geocode.reverse(
  geometry := plaza.make_point_geometry(
    coordinates := ARRAY[2.3522, 48.8566], type := 'Point'
  )
);