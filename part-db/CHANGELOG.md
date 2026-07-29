# Changelog

## 2.14.0

- Initial Home Assistant add-on wrapping the official `partdborg/part-db:v2.14.0` image.
- Maps add-on options to Part-DB environment variables.
- Persists `uploads/` (including the SQLite database) and `public/media/` to the add-on data volume via bind mounts (upstream ships these paths as Docker volumes, so they cannot be symlinked). Requires `SYS_ADMIN` and `apparmor: false`.
- Optional external MySQL/MariaDB or PostgreSQL database via `database_url`.
