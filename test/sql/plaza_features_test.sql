SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_features.retrieve(type := 'type', id := 0);

SELECT *
FROM plaza_features.batch(
  elements := ARRAY[
    plaza_features.make_batch_params_element(id := 21154906, type := 'node'),
    plaza_features.make_batch_params_element(id := 4589123, type := 'way')
  ]
);

SELECT *
FROM plaza_features.query();