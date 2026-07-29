#!/usr/bin/env bash
# Home Assistant add-on launcher for the official Part-DB image.
# Reads /data/options.json, exports Part-DB env vars, persists data to /data,
# then execs the upstream entrypoint.
set -euo pipefail

OPTIONS=/data/options.json

log() { echo "[part-db] $*"; }

# Read a string option (empty string if unset/null).
get() { jq -r --arg k "$1" '.[$k] // empty' "$OPTIONS"; }

# Read a boolean option as 1/0 (Part-DB expects 1/0 for several flags).
getbool01() {
  [ "$(jq -r --arg k "$1" '.[$k] // false' "$OPTIONS")" = "true" ] && echo 1 || echo 0
}

# Export NAME=VALUE only when VALUE is non-empty, so we never clobber an
# image default with a blank string.
setenv() { [ -n "${2:-}" ] && export "$1=$2" || true; }

# Move a Part-DB data directory onto the persistent /data volume and bind it
# back. Seeds the persistent copy from the image on first run.
#
# Upstream declares uploads/ and public/media/ as Docker VOLUMEs (see the
# upstream Dockerfile). At runtime those paths are anonymous mount points that
# cannot be replaced with a symlink (rm -> "Device or resource busy"), and the
# attachment directories are hardcoded relative paths in the image config, so
# they cannot be relocated via env. We therefore bind-mount the persistent
# /data directory over the volume, which requires SYS_ADMIN and apparmor: false
# in config.yaml.
persist() {
  local target="$1" link="$2"
  mkdir -p "$target" "$link"

  # Already bound to the persistent copy (same device+inode)? Nothing to do.
  if [ "$(stat -c '%d:%i' "$link" 2>/dev/null)" = "$(stat -c '%d:%i' "$target" 2>/dev/null)" ]; then
    return
  fi

  # Seed the persistent copy from the image/volume contents on first run.
  if [ -z "$(ls -A "$target" 2>/dev/null)" ] && [ -n "$(ls -A "$link" 2>/dev/null)" ]; then
    cp -a "$link/." "$target/"
  fi

  mount --bind "$target" "$link"
}

# uploads/ holds attachments and (by default) the SQLite database (app.db).
persist /data/uploads /var/www/html/uploads
# public/media holds generated thumbnails and public media.
persist /data/media   /var/www/html/public/media

# --- Map add-on options to Part-DB environment variables ---
setenv DEFAULT_LANG                "$(get default_lang)"
setenv DEFAULT_TIMEZONE            "$(get default_timezone)"
setenv BASE_CURRENCY              "$(get base_currency)"
setenv INSTANCE_NAME             "$(get instance_name)"
setenv MAX_ATTACHMENT_FILE_SIZE "$(get max_attachment_file_size)"
setenv TRUSTED_PROXIES          "$(get trusted_proxies)"
export ALLOW_ATTACHMENT_DOWNLOADS="$(getbool01 allow_attachment_downloads)"
# Update check is not exposed as an option; always disable it.
export CHECK_FOR_UPDATES=0

# DB_AUTOMIGRATE must be the literal "true" to trigger the upstream migration.
[ "$(getbool01 db_automigrate)" = "1" ] && export DB_AUTOMIGRATE=true

# Optional external database. When empty, keep the image default
# (SQLite at uploads/app.db, which is persisted via /data/uploads).
setenv DATABASE_URL "$(get database_url)"

log "Starting Part-DB (lang=${DEFAULT_LANG:-} tz=${DEFAULT_TIMEZONE:-} currency=${BASE_CURRENCY:-} db=${DATABASE_URL:-sqlite})"

# Hand over to Part-DB's own entrypoint (chown + php-fpm + optional migrations)
# and the apache foreground process it normally runs as CMD.
exec /usr/local/bin/partdb-entrypoint.sh /usr/local/bin/apache2-foreground
