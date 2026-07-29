# Changelog

## 2.14.0

- Initial Home Assistant app wrapping the official `partdborg/part-db:v2.14.0` image.
- Maps app options to Part-DB environment variables.
- Update check is disabled (`CHECK_FOR_UPDATES=0`) and not exposed as an option.
- Persists `uploads/` (including the SQLite database) and `public/media/` to the app data volume via bind mounts (upstream ships these paths as Docker volumes, so they cannot be symlinked). Requires `SYS_ADMIN` and `apparmor: false`.
- Optional external MySQL/MariaDB or PostgreSQL database via `database_url`.
