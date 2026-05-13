SET datestyle = 'ISO';
SET plaza.api_key = 'My API Key';

SELECT *
FROM plaza_routing.isochrone(
  geometry := plaza.make_point_geometry(
    coordinates := ARRAY[2.3522, 48.8566], type := 'Point'
  ),
  "time" := ARRAY[1]
);

SELECT *
FROM plaza_routing.matrix(
  destinations := ARRAY[
    plaza.make_point_geometry(
      coordinates := ARRAY[2.2945, 48.8584], type := 'Point'
    )
  ],
  origins := ARRAY[
    plaza.make_point_geometry(
      coordinates := ARRAY[2.3522, 48.8566], type := 'Point'
    ),
    plaza.make_point_geometry(
      coordinates := ARRAY[2.3376, 48.8606], type := 'Point'
    )
  ]
);

SELECT *
FROM plaza_routing.nearest(
  geometry := plaza.make_point_geometry(
    coordinates := ARRAY[2.3522, 48.8566], type := 'Point'
  )
);

SELECT *
FROM plaza_routing.route(
  destination := plaza.make_point_geometry(
    coordinates := ARRAY[2.2945, 48.8584], type := 'Point'
  ),
  origin := plaza.make_point_geometry(
    coordinates := ARRAY[2.3522, 48.8566], type := 'Point'
  )
);