SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_geocode.autocomplete(q := 'q');

SELECT *
FROM plaza_geocode.batch(addresses := ARRAY['string']);

SELECT *
FROM plaza_geocode.forward(q := 'q');

SELECT *
FROM plaza_geocode.reverse(lat := 0, lng := 0);