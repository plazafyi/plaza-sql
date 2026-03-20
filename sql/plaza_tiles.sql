CREATE OR REPLACE FUNCTION plaza_tiles._get(z BIGINT, x BIGINT, y BIGINT)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  response = GD["__plaza_context__"].client.tiles.with_raw_response.get(
      z=z,
      x=x,
      y=y,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION plaza_tiles.get(z BIGINT, x BIGINT, y BIGINT)
RETURNS BYTEA
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM plaza_internal.ensure_context();
    RETURN jsonb_populate_record(NULL::BYTEA, plaza_tiles._get(z, x, y));
  END;
$$;