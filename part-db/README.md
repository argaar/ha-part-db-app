# Part-DB Home Assistant Add-on

Home Assistant add-on that runs the official
[`partdborg/part-db`](https://hub.docker.com/r/partdborg/part-db) image
(currently `v2.14.0`, multi-arch: amd64 / aarch64 / armv7).

It is a thin wrapper: a small `Dockerfile` builds on top of the published
image, and `run.sh` maps the add-on options to Part-DB environment variables
and wires persistence to the add-on data volume. Part-DB itself is not built
from source here.

See [DOCS.md](DOCS.md) for installation and configuration.
