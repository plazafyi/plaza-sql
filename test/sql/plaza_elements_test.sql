SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_elements.retrieve(type := 'type', id := 0);

SELECT *
FROM plaza_elements.batch(
  elements := ARRAY[
    plaza_elements.make_batch_params_element(id := 0, type := 'node')
  ]
);

SELECT *
FROM plaza_elements.nearby(lat := 0, lng := 0);

SELECT *
FROM plaza_elements.query();