---
title: sccache with GitHub Actions cache for Godot container builds
date: 2026-06-24
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

# sccache with GitHub Actions cache for Godot container builds

## The Context

The `fabric-godot-images` repo builds the Godot engine from source inside a podman container and publishes the result to ghcr.io. A full cold build takes 30–60 minutes. The previous CI path used `docker/build-push-action` with `cache-from/to: type=gha`, which cached OCI layers between runs. That action was replaced by plain `podman build` to align with the fabric's rootless-podman + systemd-quadlet standard. The layer cache was lost in that migration.

The previous developer-facing sccache setup forwarded Tigris S3 credentials (`SCCACHE_BUCKET`, `SCCACHE_ENDPOINT`, `SCCACHE_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) as podman build args and secrets. CI did not use sccache at all.

## The Problem Statement

CI `build-docker` runs have no compiler-output cache. Every push that triggers the workflow recompiles the full Godot engine from scratch, spending 30–60 minutes on work that was already done the previous run. sccache has a native GitHub Actions cache backend (`SCCACHE_GHA_ENABLED=true`) that can restore compiler-output entries across runs without an external storage account, but it requires `ACTIONS_CACHE_URL` and `ACTIONS_RUNTIME_TOKEN` to be reachable from inside the container where sccache runs.

## Design

Add `SCCACHE_GHA_ENABLED` as a build arg in `Containerfile` and expose it through the environment so sccache picks it up. Mount `ACTIONS_CACHE_URL` and `ACTIONS_RUNTIME_TOKEN` as podman build secrets on the `scons` RUN step; export them in the shell before the compiler is invoked.

**`Containerfile` (build stage)**

```dockerfile
ARG SCCACHE_GHA_ENABLED=""
# … existing ENV block …
ARG SCCACHE_GHA_ENABLED
ENV SCCACHE_GHA_ENABLED=${SCCACHE_GHA_ENABLED}

RUN --mount=type=secret,id=ACTIONS_CACHE_URL \
    --mount=type=secret,id=ACTIONS_RUNTIME_TOKEN \
    --mount=type=cache,target=/root/.cache/sccache,sharing=locked \
    export ACTIONS_CACHE_URL="$(cat /run/secrets/ACTIONS_CACHE_URL 2>/dev/null || true)" && \
    export ACTIONS_RUNTIME_TOKEN="$(cat /run/secrets/ACTIONS_RUNTIME_TOKEN 2>/dev/null || true)" && \
    scons platform=linuxbsd \
        target="${TARGET}" \
        precision=double \
        c_compiler_launcher=sccache \
        cpp_compiler_launcher=sccache \
        -j"$(nproc)" && \
    sccache --show-stats && \
    strip "bin/${BINARY_NAME}"
```

**`.github/workflows/build.yml` (`build-docker` job)**

```yaml
- name: Build and push image (podman)
  run: |
    podman build \
      --build-arg TARGET="…" \
      --build-arg BINARY_NAME="…" \
      --build-arg SCCACHE_GHA_ENABLED=true \
      --secret id=ACTIONS_CACHE_URL,env=ACTIONS_CACHE_URL \
      --secret id=ACTIONS_RUNTIME_TOKEN,env=ACTIONS_RUNTIME_TOKEN \
      --build-context "godot-src=${{ github.workspace }}/godot" \
      --file Containerfile \
      --tag "${{ matrix.image }}:latest" \
      .
    podman push "${{ matrix.image }}:latest"
```

`ACTIONS_CACHE_URL` and `ACTIONS_RUNTIME_TOKEN` are set automatically on every GHA runner; no repo secrets are required. They are passed via `--secret` rather than `--build-arg` so they are never baked into an image layer or visible in `podman history`.

For local `just build-docker` runs the build arg and secrets are absent; sccache falls back to the on-disk cache at `~/.cache/sccache`.

## The Downsides

- GHA cache has a 10 GB per-repo limit with LRU eviction. A full dual-target sccache population is 2–4 GB, which fits, but will compete with other caches in the same repo.
- Cache entries are scoped to the branch that wrote them, with fallback to the default branch. PRs from forks have read-only access to the parent repo's cache.
- The `--mount=type=cache` for `/root/.cache/sccache` is a no-op when the GHA backend is active (sccache does not write to disk in that mode), so it adds a small mount with no benefit in CI.

## The Road Not Taken

- Tigris S3 bucket: previously used for local builds; needs an external account, five repo secrets, and ongoing cost. Removed for the zero-config GHA cache.
- OCI layer cache via `actions/cache`: podman's build layer cache lives in `~/.local/share/containers/storage/`, a blob store that is expensive to tar and restore. sccache caches compiler outputs at finer granularity and transfers better across minor source changes.
- Host sccache server + `--network=host`: avoids the secret mount but changes container network behaviour and needs sccache installed on the host separately from the in-container copy.
