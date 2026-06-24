# Derived GitLab toolbox image with a PostgreSQL 18 client.
#
# Why: this chart runs a hand-rolled PostgreSQL 18 server, but the stock
# gitlab-toolbox-ee image ships a <18 client. `pg_dump` refuses to dump a
# server whose major version is newer than the client, so `gitlab-backup`
# (which shells out to the toolbox's pg_dump) cannot back up the database.
# This image adds the pgdg postgresql-client-18 and points the default client
# tools at v18 so gitlab-backup works end-to-end.
#
# Build (override REGISTRY to pull the base through a proxy-cache, and set
# GITLAB_VERSION to the GitLab release you deploy):
#   docker build \
#     --build-arg REGISTRY=registry.gitlab.com \
#     --build-arg GITLAB_VERSION=v19.1.1 \
#     -t <your-registry>/gitlab-toolbox-pg18:v19.1.1 .
# Then set gitlab.gitlab.toolbox.image.{repository,tag} in your values.
ARG REGISTRY=registry.gitlab.com
ARG GITLAB_VERSION=v19.1.1
FROM ${REGISTRY}/gitlab-org/build/cng/gitlab-toolbox-ee:${GITLAB_VERSION}

# Base is Debian 12 (bookworm); toolbox runs as uid 1000 (git) at runtime.
USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg; \
    install -d /usr/share/postgresql-common/pgdg; \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc; \
    echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends postgresql-client-18; \
    # Make the v18 client tools the default ones on PATH (the base put real
    # <18 binaries directly in /usr/bin, so override them with symlinks to v18).
    for b in psql pg_dump pg_dumpall pg_restore pg_basebackup pg_isready; do \
      ln -sf /usr/lib/postgresql/18/bin/$b /usr/bin/$b; \
    done; \
    apt-get purge -y --auto-remove gnupg; \
    rm -rf /var/lib/apt/lists/*; \
    # Fail the build if the default pg_dump is not v18.
    pg_dump --version | grep -E '\b18\.'

# Restore the upstream runtime user so the toolbox entrypoint behaves unchanged.
USER git
