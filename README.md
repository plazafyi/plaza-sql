# Plaza API PostgreSQL Extension

> [!NOTE]
>
> The Plaza API PostgreSQL Extension is currently **experimental** and we're excited for you to experiment with it!
>
> This extension has not yet been exhaustively tested in production environments and may be missing some features you'd expect in a stable release. As we continue development, there may be breaking changes that require updates to your code.
>
> **We'd love your feedback!** Please share any suggestions, bug reports, feature requests, or general thoughts by [filing an issue](https://www.github.com/plazafyi/plaza-sql/issues/new).

The Plaza API PostgreSQL Extension provides convenient access to the [Plaza REST API](https://docs.plaza.fyi) from PostgreSQL.

It is generated with [Stainless](https://www.stainless.com/).

The REST API documentation can be found on [docs.plaza.fyi](https://docs.plaza.fyi).

## Installation

Install the extension from [PGXN](https://pgxn.org/dist/plaza):

```sh
pgxn install plaza
```

Load it into your database:

```sh
pgxn load -d yourb plaza
```

And install the Python SDK dependency:

```sh
# install from PyPI
pip install plaza
```

See [PGXN Client's documentation](https://pgxn.github.io/pgxnclient) for more information on installing from PGXN, and [`./scripts/test`](./scripts/test) how to use a [Python virtual environment](https://docs.python.org/3/library/sys_path_init.html#sys-path-init-virtual-environments) if you prefer that instead.

Use [the troubleshooting section](#troubleshooting) if you encounter issues during or after installation.

## Requirements

This extension requires:

- PostgreSQL 14 or higher
- [PL/Python](https://www.postgresql.org/docs/current/plpython.html)
- Python 3.9 or higher
- The plaza Python package

## Usage

```sql
SELECT *
FROM plaza_elements.nearby(lat := 48.8584, lng := 0, radius := 500);
```

## Client configuration

Configure the client by setting configuration parameters at the database level:

```sql
ALTER DATABASE my_database SET plaza.api_key = 'My API Key';
```

> [!NOTE]
>
> `ALTER DATABASE` persistently alters the database, but doesn't take effect until the next session. To
> ephemerally modify the current session, use `SET plaza.api_key TO 'My API Key';`.

See this table for the available configuration parameters:

| Parameter           | Required | Default value         |
| ------------------- | -------- | --------------------- |
| `plaza.api_key`     | true     | -                     |
| `plaza.base_url`    | false    | `'https://plaza.fyi'` |
| `plaza.environment` | false    | `'production'`        |

`plaza.environment` supports the following values:

- `production`
- `local`

## Requests and responses

To send a request to the Plaza API, call the relevant SQL function with values corresponding to the parameter types and `SELECT` the columns you need from the returned rows.

To construct [composite type](https://www.postgresql.org/docs/current/rowtypes.html) parameters, use the parameter type's provided `make_*` function. For example, `plaza.geo_json_geometry` may be constructed like so:

```sql
plaza.make_geo_json_geometry(
  coordinates := ARRAY[
    $$
    0
    $$::JSONB
  ],
  type := 'Point'
)
```

## Manual installation

Clone the repository:

```sh
git clone git@github.com:plazafyi/plaza-sql.git
cd plaza-sql
```

Install the extension:

```sh
make install
```

Load it into the relevant database:

```sql
CREATE EXTENSION IF NOT EXISTS plpython3u; -- Dependency
CREATE EXTENSION plaza;
```

And install the Python SDK dependency:

```sh
# install from PyPI
pip install plaza
```

See [`./scripts/test`](./scripts/test) how to use a [Python virtual environment](https://docs.python.org/3/library/sys_path_init.html#sys-path-init-virtual-environments) if you prefer that instead.

Use [the troubleshooting section](#troubleshooting) if you encounter issues during or after installation.

## Troubleshooting

### Installation

If you encounter an error such as:

```
Operation not permitted
```

Then run with `sudo`. If necessary, ensure your terminal has full disk access.

If you encounter an error such as:

```
make: pg_config: Command not found
```

Then ensure you have `pg_config` installed and in your `PATH`. If necessary, tell `make` where to find it:

```sh
PG_CONFIG=/path/to/pg_config make install
```

To install the extension in a custom prefix on PostgreSQL 18 or later, pass the `prefix` argument:

```sh
make install prefix=/usr/local/extras
```

You must also ensure that the prefix is included in the following [`postgresql.conf` parameters](https://www.postgresql.org/docs/current/config-setting.html#CONFIG-SETTING-CONFIGURATION-FILE):

```conf
extension_control_path = '/usr/local/extras/postgresql/share:$system'
dynamic_library_path   = '/usr/local/extras/postgresql/lib:$libdir'
```

### Loading

If you encounter an error such as:

```
ERROR: could not load library
```

Then ensure your Python installation is linked to the directory where PostgreSQL was looking for it. You can print out the directory of your Python installation with this command:

```sh
python3 -c "import sys; print(sys.prefix)"
```

## Semantic versioning

This package generally follows [SemVer](https://semver.org/spec/v2.0.0.html) conventions, though certain backwards-incompatible changes may be released as minor versions:

1. Changes to library internals which are technically public but not intended or documented for external use. _(Please open a GitHub issue to let us know if you are relying on such internals.)_
2. Changes that we do not expect to impact the vast majority of users in practice.

We take backwards-compatibility seriously and work hard to ensure you can rely on a smooth upgrade experience.

We are keen for your feedback; please open an [issue](https://www.github.com/plazafyi/plaza-sql/issues) with questions, bugs, or suggestions.
