SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_datasets.create(name := 'name', slug := 'slug');

SELECT *
FROM plaza_datasets.retrieve(id := 'id');

SELECT *
FROM plaza_datasets.list();

SELECT *
FROM plaza_datasets.delete(id := 'id');

SELECT *
FROM plaza_datasets.features(id := 'id');