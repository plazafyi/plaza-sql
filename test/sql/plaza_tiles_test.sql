SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_tiles.get(z := 0, x := 0, y := 0);