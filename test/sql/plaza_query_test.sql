SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_query.overpass(data := 'data');

SELECT *
FROM plaza_query.sparql(query := 'query');