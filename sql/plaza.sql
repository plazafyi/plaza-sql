ALTER TYPE plaza.error
  ADD ATTRIBUTE error plaza.error_error;

CREATE OR REPLACE FUNCTION plaza.make_error(error plaza.error_error)
RETURNS plaza.error
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(error)::plaza.error;
$$;

ALTER TYPE plaza.error_error
  ADD ATTRIBUTE code TEXT,
  ADD ATTRIBUTE message TEXT,
  ADD ATTRIBUTE details JSONB;

CREATE OR REPLACE FUNCTION plaza.make_error_error(
  code TEXT, message TEXT, details JSONB DEFAULT NULL
)
RETURNS plaza.error_error
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(code, message, details)::plaza.error_error;
$$;

ALTER TYPE plaza.feature_collection
  ADD ATTRIBUTE features plaza.geo_json_feature[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_feature_collection(
  features plaza.geo_json_feature[], type TEXT
)
RETURNS plaza.feature_collection
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(features, type)::plaza.feature_collection;
$$;

ALTER TYPE plaza.geo_json_feature
  ADD ATTRIBUTE geometry plaza.geometry,
  ADD ATTRIBUTE properties JSONB,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE id TEXT;

CREATE OR REPLACE FUNCTION plaza.make_geo_json_feature(
  geometry plaza.geometry, properties JSONB, type TEXT, id TEXT DEFAULT NULL
)
RETURNS plaza.geo_json_feature
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry, properties, type, id)::plaza.geo_json_feature;
$$;

ALTER TYPE plaza.geometry
  ADD ATTRIBUTE coordinates JSONB[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_geometry(coordinates JSONB[], type TEXT)
RETURNS plaza.geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.geometry;
$$;

ALTER TYPE plaza.line_string_geometry
  ADD ATTRIBUTE coordinates DOUBLE PRECISION[][], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_line_string_geometry(
  coordinates DOUBLE PRECISION[][], type TEXT
)
RETURNS plaza.line_string_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.line_string_geometry;
$$;

ALTER TYPE plaza.multi_line_string_geometry
  ADD ATTRIBUTE coordinates DOUBLE PRECISION[][][], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_multi_line_string_geometry(
  coordinates DOUBLE PRECISION[][][], type TEXT
)
RETURNS plaza.multi_line_string_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.multi_line_string_geometry;
$$;

ALTER TYPE plaza.multi_point_geometry
  ADD ATTRIBUTE coordinates DOUBLE PRECISION[][], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_multi_point_geometry(
  coordinates DOUBLE PRECISION[][], type TEXT
)
RETURNS plaza.multi_point_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.multi_point_geometry;
$$;

ALTER TYPE plaza.multi_polygon_geometry
  ADD ATTRIBUTE coordinates DOUBLE PRECISION[][][][], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_multi_polygon_geometry(
  coordinates DOUBLE PRECISION[][][][], type TEXT
)
RETURNS plaza.multi_polygon_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.multi_polygon_geometry;
$$;

ALTER TYPE plaza.point_geometry
  ADD ATTRIBUTE coordinates DOUBLE PRECISION[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_point_geometry(
  coordinates DOUBLE PRECISION[], type TEXT
)
RETURNS plaza.point_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.point_geometry;
$$;

ALTER TYPE plaza.polygon_geometry
  ADD ATTRIBUTE coordinates DOUBLE PRECISION[][][], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_polygon_geometry(
  coordinates DOUBLE PRECISION[][][], type TEXT
)
RETURNS plaza.polygon_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.polygon_geometry;
$$;

ALTER TYPE plaza.validation_error
  ADD ATTRIBUTE error plaza.validation_error_error;

CREATE OR REPLACE FUNCTION plaza.make_validation_error(
  error plaza.validation_error_error
)
RETURNS plaza.validation_error
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(error)::plaza.validation_error;
$$;

ALTER TYPE plaza.validation_error_error
  ADD ATTRIBUTE code TEXT,
  ADD ATTRIBUTE message TEXT,
  ADD ATTRIBUTE details JSONB;

CREATE OR REPLACE FUNCTION plaza.make_validation_error_error(
  code TEXT, message TEXT, details JSONB DEFAULT NULL
)
RETURNS plaza.validation_error_error
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(code, message, details)::plaza.validation_error_error;
$$;