CREATE OR REPLACE FUNCTION plaza_search._query(
  q TEXT,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_sort TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.search.with_raw_response.query(
      q=q,
      cursor=not_given if cursor is None else cursor,
      format=not_given if format is None else format,
      limit=not_given if limit is None else limit,
      output_fields=not_given if output_fields is None else output_fields,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_sort=not_given if output_sort is None else output_sort,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_search.query(
  q TEXT,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_sort TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_search._query(
        q,
        cursor,
        format,
        "limit",
        output_fields,
        output_include,
        output_precision,
        output_sort
      )
    );
  END;
$$;

CREATE OR REPLACE FUNCTION plaza_search._query_post(
  q TEXT,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_sort TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
AS $$
  from plaza._types import not_given

  response = GD["__plaza_context__"].client.search.with_raw_response.query_post(
      q=q,
      cursor=not_given if cursor is None else cursor,
      format=not_given if format is None else format,
      limit=not_given if limit is None else limit,
      output_fields=not_given if output_fields is None else output_fields,
      output_include=not_given if output_include is None else output_include,
      output_precision=not_given if output_precision is None else output_precision,
      output_sort=not_given if output_sort is None else output_sort,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_search.query_post(
  q TEXT,
  cursor TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  "limit" BIGINT DEFAULT NULL,
  output_fields TEXT DEFAULT NULL,
  output_include TEXT DEFAULT NULL,
  output_precision BIGINT DEFAULT NULL,
  output_sort TEXT DEFAULT NULL
)
RETURNS plaza.feature_collection
LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::plaza.feature_collection,
      plaza_search._query_post(
        q,
        cursor,
        format,
        "limit",
        output_fields,
        output_include,
        output_precision,
        output_sort
      )
    );
  END;
$$;