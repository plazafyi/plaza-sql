SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_search.query(q := 'q');