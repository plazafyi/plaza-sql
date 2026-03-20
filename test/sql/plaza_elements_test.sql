SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_elements.retrieve(type := 'type', id := 0);

SELECT *
FROM plaza_elements.batch(
  elements := ARRAY[
    plaza_elements.make_batch_params_element(id := 21154906, type := 'node'),
    plaza_elements.make_batch_params_element(id := 4589123, type := 'way')
  ]
);

SELECT *
FROM plaza_elements.lookup();

SELECT *
FROM plaza_elements.nearby();

SELECT *
FROM plaza_elements.nearby_post();

SELECT *
FROM plaza_elements.query();

SELECT *
FROM plaza_elements.query_post();