ALTER TYPE plaza_features.batch_request
  ADD ATTRIBUTE elements plaza_features.batch_request_element[];

CREATE OR REPLACE FUNCTION plaza_features.make_batch_request(
  elements plaza_features.batch_request_element[]
)
RETURNS plaza_features.batch_request
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(elements)::plaza_features.batch_request;
$$;

ALTER TYPE plaza_features.batch_request_element
  ADD ATTRIBUTE id BIGINT, ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_features.make_batch_request_element(
  id BIGINT, type TEXT
)
RETURNS plaza_features.batch_request_element
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(id, type)::plaza_features.batch_request_element;
$$;

ALTER TYPE plaza_features.spatial_predicate
  ADD ATTRIBUTE around plaza.geometry,
  ADD ATTRIBUTE contains plaza.geometry,
  ADD ATTRIBUTE crosses plaza.geometry,
  ADD ATTRIBUTE intersects plaza.geometry,
  ADD ATTRIBUTE not_contains plaza.geometry,
  ADD ATTRIBUTE not_intersects plaza.geometry,
  ADD ATTRIBUTE not_within plaza.geometry,
  ADD ATTRIBUTE radius DOUBLE PRECISION,
  ADD ATTRIBUTE touches plaza.geometry,
  ADD ATTRIBUTE within plaza.geometry;

CREATE OR REPLACE FUNCTION plaza_features.make_spatial_predicate(
  around plaza.geometry DEFAULT NULL,
  contains plaza.geometry DEFAULT NULL,
  crosses plaza.geometry DEFAULT NULL,
  intersects plaza.geometry DEFAULT NULL,
  not_contains plaza.geometry DEFAULT NULL,
  not_intersects plaza.geometry DEFAULT NULL,
  not_within plaza.geometry DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL,
  touches plaza.geometry DEFAULT NULL,
  within plaza.geometry DEFAULT NULL
)
RETURNS plaza_features.spatial_predicate
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    around,
    contains,
    crosses,
    intersects,
    not_contains,
    not_intersects,
    not_within,
    radius,
    touches,
    within
  )::plaza_features.spatial_predicate;
$$;

ALTER TYPE plaza_features.batch_params_element
  ADD ATTRIBUTE id BIGINT, ADD ATTRIBUTE type TEXT;

CREATE OR REPLACE FUNCTION plaza_features.make_batch_params_element(
  id BIGINT, type TEXT
)
RETURNS plaza_features.batch_params_element
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(id, type)::plaza_features.batch_params_element;
$$;

CREATE OR REPLACE FUNCTION plaza_features._retrieve(type TEXT, id BIGINT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.features.with_raw_response.retrieve(
      type=type,
      id=id,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_features.retrieve(type TEXT, id BIGINT)
RETURNS plaza.geo_json_feature
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.geo_json_feature, plaza_features._retrieve(type, id)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_features._batch(
  elements plaza_features.batch_params_element[]
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  response = GD["__plaza_context__"].client.features.with_raw_response.batch(
      elements=GD["__plaza_context__"].strip_none(elements),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_features.batch(
  elements plaza_features.batch_params_element[]
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection, plaza_features._batch(elements)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_features._query(
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL,
  around plaza.geometry DEFAULT NULL,
  contains plaza.geometry DEFAULT NULL,
  crosses plaza.geometry DEFAULT NULL,
  intersects plaza.geometry DEFAULT NULL,
  not_contains plaza.geometry DEFAULT NULL,
  not_intersects plaza.geometry DEFAULT NULL,
  not_within plaza.geometry DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL,
  touches plaza.geometry DEFAULT NULL,
  within plaza.geometry DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.features.with_raw_response.query(
      cursor=not_given if cursor is None else cursor,
      format=not_given if format is None else format,
      h3=not_given if h3 is None else h3,
      limit=not_given if limit is None else limit,
      type=not_given if type is None else type,
      around=not_given if around is None else GD["__plaza_context__"].strip_none(around),
      contains=not_given if contains is None else GD["__plaza_context__"].strip_none(contains),
      crosses=not_given if crosses is None else GD["__plaza_context__"].strip_none(crosses),
      intersects=not_given if intersects is None else GD["__plaza_context__"].strip_none(intersects),
      not_contains=not_given if not_contains is None else GD["__plaza_context__"].strip_none(not_contains),
      not_intersects=not_given if not_intersects is None else GD["__plaza_context__"].strip_none(not_intersects),
      not_within=not_given if not_within is None else GD["__plaza_context__"].strip_none(not_within),
      radius=not_given if radius is None else radius,
      touches=not_given if touches is None else GD["__plaza_context__"].strip_none(touches),
      within=not_given if within is None else GD["__plaza_context__"].strip_none(within),
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_features.query(
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  h3 TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL,
  around plaza.geometry DEFAULT NULL,
  contains plaza.geometry DEFAULT NULL,
  crosses plaza.geometry DEFAULT NULL,
  intersects plaza.geometry DEFAULT NULL,
  not_contains plaza.geometry DEFAULT NULL,
  not_intersects plaza.geometry DEFAULT NULL,
  not_within plaza.geometry DEFAULT NULL,
  radius DOUBLE PRECISION DEFAULT NULL,
  touches plaza.geometry DEFAULT NULL,
  within plaza.geometry DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_features._query(
        cursor,
        format,
        h3,
        "limit",
        type,
        around,
        contains,
        crosses,
        intersects,
        not_contains,
        not_intersects,
        not_within,
        radius,
        touches,
        within
      )
    );
  END;
$$;