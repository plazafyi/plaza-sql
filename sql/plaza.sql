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
  ADD ATTRIBUTE geometry plaza.geo_json_geometry,
  ADD ATTRIBUTE properties JSONB,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE id TEXT,
  ADD ATTRIBUTE osm_id BIGINT;

CREATE OR REPLACE FUNCTION plaza.make_geo_json_feature(
  geometry plaza.geo_json_geometry,
  properties JSONB,
  type TEXT,
  id TEXT DEFAULT NULL,
  osm_id BIGINT DEFAULT NULL
)
RETURNS plaza.geo_json_feature
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(geometry, properties, type, id, osm_id)::plaza.geo_json_feature;
$$;

ALTER TYPE plaza.geo_json_geometry
  ADD ATTRIBUTE coordinates JSONB[], ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza.make_geo_json_geometry(
  coordinates JSONB[], type TEXT
)
RETURNS plaza.geo_json_geometry
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(coordinates, type)::plaza.geo_json_geometry;
$$;