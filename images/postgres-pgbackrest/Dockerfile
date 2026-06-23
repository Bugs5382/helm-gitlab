# Thin derived image: official PostgreSQL 18 + pgBackRest.
# Build: docker build --build-arg REGISTRY=docker.io -t myregistry/postgres-pgbackrest:18 .
# Override REGISTRY to pull the base image from a proxy-cache.
ARG REGISTRY=docker.io
FROM ${REGISTRY}/library/postgres:18

# pgBackRest from Debian; the postgres:18 base is Debian trixie.
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends pgbackrest \
 && rm -rf /var/lib/apt/lists/*

# Restore the base image's runtime user (postgres, uid 999) so the
# container inherits the upstream entrypoint behavior unchanged.
USER postgres
