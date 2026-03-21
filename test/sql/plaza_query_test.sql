SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_query.execute(
  steps := ARRAY[
    plaza_query.make_execute_params_step(type := 'overpass', query := 'query')
  ]
);

SELECT *
FROM plaza_query.overpass(
  data := '[out:json];node[amenity=cafe](around:500,48.8566,2.3522);out body;'
);