# Changelog

## 2.14.0_5

- Override `STOPSIGNAL` to `SIGTERM` so the app stops gracefully. The upstream image inherits `STOPSIGNAL SIGWINCH` (an Apache leftover) which FrankenPHP ignores, causing stop to time out and Docker to SIGKILL the container (exit code 137).

## 2.14.0_4

- Persist data in the `addon_config` folder (`/config`, host `/addon_configs/<slug>`) instead of `/data`, so the database, uploads, media, and `APP_SECRET` survive an uninstall/reinstall (Home Assistant always wipes `/data` on uninstall, but keeps `addon_config` unless "Also remove app data" is checked). Existing `/data` data is migrated automatically on first start.

## 2.14.0_3

- Make direct host-port access optional and unmapped by default; Ingress is now the default access path. Map a host port under Network to reach Part-DB outside Home Assistant. Removed the `webui`/`watchdog` port references (Ingress provides the Open Web UI button).

## 2.14.0_2

- Add Home Assistant Ingress support (sidebar panel) while keeping direct access on host port `8085`. Caddy maps HA's `X-Ingress-Path` to `X-Forwarded-Prefix` for correct sub-path URLs and strips `X-Frame-Options` so the app can be embedded in the HA UI.

## 2.14.0_1

- Generate a unique random `APP_SECRET` on first start and persist it on `/data`, replacing the insecure default shipped with the image. Stays stable across restarts and updates.
- Add optional `trusted_hosts` option (maps to `TRUSTED_HOSTS`) to restrict the host names Part-DB accepts. Empty by default.

## 2.14.0_0

- Initial Home Assistant app wrapping the official `partdborg/part-db:v2.14.0` image (FrankenPHP variant).
- Maps app options to Part-DB environment variables.
- Update check is disabled (`CHECK_FOR_UPDATES=0`) and not exposed as an option.
- Serves the UI over plain HTTP on port 80 by setting `SERVER_NAME=:80` for FrankenPHP/Caddy.
- Persists Part-DB's `/app/uploads` (including the SQLite database) and `/app/public/media` to the app data volume via symlinks.
- Optional external MySQL/MariaDB or PostgreSQL database via `database_url`.
