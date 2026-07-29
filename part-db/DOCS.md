# Part-DB app

Runs [Part-DB](https://github.com/Part-DB/Part-DB-server), an open source
inventory management system for electronic components, from the official
`partdborg/part-db` Docker image.

## Installation

1. In Home Assistant go to **Settings -> Apps -> Install Apps**.
2. Open the three-dot menu, choose **Repositories**, and add:
   `https://github.com/argaar/ha-part-db-app`
3. Go back to the **Store** and install the **Part-DB** app (scroll down if
   you can't find it).
4. Review the options below, then **Start** the app.
5. Open the Web UI (host port `8085` by default).

On first start Part-DB creates the database and an administrator account. Watch
the app log: the initial admin password is printed there the first time the
database is initialized. Log in with user `admin` and that password, then
change it.

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `default_lang` | `en` | Default UI language. |
| `default_timezone` | `Europe/Rome` | PHP timezone identifier. |
| `base_currency` | `EUR` | Reference currency (ISO 4217). |
| `instance_name` | `Part-DB` | Name shown in the UI. |
| `allow_attachment_downloads` | `false` | Allow downloading attachments from URLs. |
| `max_attachment_file_size` | `100M` | Attachment upload limit. |
| `db_automigrate` | `true` | Run DB migrations on start (backup taken first). |
| `trusted_proxies` | `172.30.32.0/23,127.0.0.0/8,::1` | Trusted reverse-proxy ranges. |
| `trusted_hosts` | (empty) | Optional unquoted regex of allowed host names, e.g. `^(192\.168\.1\.253)$`. Empty = accept any host. |
| `database_url` | (empty) | Optional external DB DSN. Empty = built-in SQLite. |

## Data persistence

The app stores all mutable data on its persistent data volume:

- `uploads/` -> `/data/uploads` (attachments and, by default, the SQLite
  database `app.db`).
- `public/media/` -> `/data/media` (generated thumbnails and public media).

The app symlinks Part-DB's `/app/uploads` and `/app/public/media` directories
to these persistent locations on start. A unique random `APP_SECRET` is also
generated on first start and stored at `/data/app_secret`, replacing the
insecure default shipped with the image.

These survive app restarts and updates. Back up the app to preserve them.

## Using an external database

Set `database_url` to a Doctrine DSN to use MySQL/MariaDB or PostgreSQL instead
of SQLite, for example:

```
mysql://partdb:secret@core-mariadb:3306/partdb?serverVersion=10.11.2-MariaDB
postgresql://partdb:secret@host:5432/partdb?serverVersion=16&charset=utf8
```

With `db_automigrate` enabled the schema is created and upgraded automatically.

## Updating Part-DB

This app pins a specific upstream version. To move to a newer Part-DB
release, edit `build.yaml` (the `partdborg/part-db:vX.Y.Z` tags) and the
`version` in `config.yaml`, then rebuild the app.

## Notes and limitations

- No Home Assistant Ingress. Part-DB (Symfony) does not run reliably under an
  Ingress sub-path, so the UI is exposed on a mapped TCP port instead.
- The app runs the container as the image ships it (FrankenPHP/Caddy serving
  plain HTTP on port 80, mapped to host `8085`).
