SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_query.execute(
  data := '$$ = search(node, amenity: "cafe").around(distance: 500, geometry: point(48.8566, 2.3522));'
);