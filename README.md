# Part-DB Home Assistant App

Home Assistant app that runs [Part-DB](https://github.com/Part-DB/Part-DB-server),
an open source inventory system for electronic components, from the official
[`partdborg/part-db`](https://hub.docker.com/r/partdborg/part-db) Docker image.

Currently tracks Part-DB **v2.14.0** (multi-arch: amd64 / aarch64 / armv7).

This repository is a thin wrapper. A small `Dockerfile` builds on top of the
published image, and `run.sh` maps the app options to Part-DB environment
variables and wires persistence to the app data volume. Part-DB itself is not
built from source here, so the app stays close to upstream and is easy to
bump to new releases.

## Install

1. In Home Assistant go to **Settings -> Apps -> Apps Store**.
2. Open the three-dot menu, choose **Repositories**, and add:
   `https://github.com/argaar/ha-part-db-app`
3. Install the **Part-DB** app.
4. Review the options, then **Start** it.
5. Open the Web UI (host port `8085` by default).

On first start Part-DB creates the database and an administrator account. The
initial `admin` password is printed in the app log the first time the
database is initialized. Log in and change it.

Full configuration and data-persistence details: [part-db/DOCS.md](part-db/DOCS.md).

## Layout

```
.
├── repository.yaml        # marks this repo as an HA app repository
└── part-db/               # the app (slug: part_db)
    ├── config.yaml        # manifest: arch, ports, options, schema
    ├── build.yaml         # base image tag per architecture
    ├── Dockerfile         # thin wrapper: adds jq + run.sh on top of the image
    ├── run.sh             # maps options to env vars, wires /data persistence
    ├── DOCS.md            # user documentation
    ├── CHANGELOG.md
    ├── translations/      # option labels shown in the HA UI
    └── icon.png / logo.png
```

## Updating Part-DB

The app pins a concrete upstream image tag for reproducible builds. To move
to a newer Part-DB release:

1. Bump the `partdborg/part-db:vX.Y.Z` tags in [part-db/build.yaml](part-db/build.yaml).
2. Bump `version` in [part-db/config.yaml](part-db/config.yaml) to match.
3. Add an entry to [part-db/CHANGELOG.md](part-db/CHANGELOG.md).

Before bumping, confirm the target image is still Apache-based (port 80,
`partdb-entrypoint.sh` + `apache2-foreground`). A FrankenPHP-based tag would
require changes to `run.sh`.

## License

See [LICENSE](LICENSE). Part-DB itself is licensed AGPL-3.0-or-later.
