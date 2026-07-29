# Changelog

## 2.14.0

- Initial Home Assistant app wrapping the official `partdborg/part-db:v2.14.0` image (FrankenPHP variant).
- Maps app options to Part-DB environment variables.
- Update check is disabled (`CHECK_FOR_UPDATES=0`) and not exposed as an option.
- Serves the UI over plain HTTP on port 80 by setting `SERVER_NAME=:80` for FrankenPHP/Caddy.
- Persists Part-DB's `/app/uploads` (including the SQLite database) and `/app/public/media` to the app data volume via symlinks.
- Optional external MySQL/MariaDB or PostgreSQL database via `database_url`.
