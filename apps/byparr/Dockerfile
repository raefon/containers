FROM ghcr.io/raefon/ubuntu:jammy-20251013@sha256:4cf9650d9ae8dbce0faf65131fe01f9a20b23353a4900f836a0e2bba5d3c371d AS build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETOS=linux
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION
ARG GITHUB_BUILD=false

ENV GITHUB_BUILD="${GITHUB_BUILD}" \
    VERSION="${VERSION}" \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_CACHE_DIR=/tmp/uv-cache \
    PORT=8191 \
    XDG_CACHE_HOME=/cache \
    HOME=/tmp

WORKDIR /app

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      tar \
      gzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN set -eux; \
    for tag in "v${VERSION}" "release-${VERSION}" "${VERSION}"; do \
      echo "Trying Byparr tag: ${tag}"; \
      if curl -fsSL "https://github.com/ThePhaseless/Byparr/archive/refs/tags/${tag}.tar.gz" \
        | tar xzf - -C /app --strip-components 1; then \
        echo "Downloaded Byparr ${tag}"; \
        break; \
      fi; \
    done; \
    test -f /app/pyproject.toml

RUN mkdir -p /cache && \
    uv sync --no-dev && \
    uv run camoufox fetch && \
    uv cache clean && \
    chmod -R o+rX /app /opt/uv/python && \
    chmod -R o+rwX /cache && \
    find /app/.venv -path "*/camoufox_add_init_script/addon" -type d -exec chmod -R o+rwX {} +

FROM ghcr.io/raefon/ubuntu:jammy-20251013@sha256:4cf9650d9ae8dbce0faf65131fe01f9a20b23353a4900f836a0e2bba5d3c371d

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG VERSION
ARG GITHUB_BUILD=false

ENV GITHUB_BUILD="${GITHUB_BUILD}" \
    VERSION="${VERSION}" \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    PORT=8191 \
    XDG_CACHE_HOME=/cache \
    HOME=/tmp \
    PATH="/app/.venv/bin:${PATH}"

WORKDIR /app

COPY --from=build /opt/uv/python /opt/uv/python
COPY --from=build /cache /cache
COPY --from=build /app /app
COPY ./apps/byparr/entrypoint.sh /entrypoint.sh

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl && \
    /app/.venv/bin/python -m playwright install-deps firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /entrypoint.sh && \
    chmod -R o+rX /app /opt/uv/python && \
    chmod -R o+rwX /cache && \
    find /app/.venv -path "*/camoufox_add_init_script/addon" -type d -exec chmod -R o+rwX {} +

USER kah
#EXPOSE 8191
#HEALTHCHECK --interval=15m --timeout=30s --start-period=5s --retries=3 CMD curl -fsS "http://localhost:${PORT}/health"
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/ThePhaseless/Byparr"
