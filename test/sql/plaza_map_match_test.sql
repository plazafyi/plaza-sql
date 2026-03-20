SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_map_match.match(
  coordinates := ARRAY[
    plaza_map_match.make_match_params_coordinate(lat := 48.8566, lng := 2.3522),
    plaza_map_match.make_match_params_coordinate(lat := 48.857, lng := 2.353),
    plaza_map_match.make_match_params_coordinate(lat := 48.8575, lng := 2.354)
  ]
);