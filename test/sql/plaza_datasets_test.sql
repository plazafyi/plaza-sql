SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_datasets.create(name := 'NYC Bike Lanes', slug := 'nyc-bike-lanes');

SELECT *
FROM plaza_datasets.retrieve(id := 'id');

SELECT *
FROM plaza_datasets.list();

SELECT *
FROM plaza_datasets.delete(id := 'id');