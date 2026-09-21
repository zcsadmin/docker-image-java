# AGENTS.md

Docker image builder repo for `zcscompany/java` images on Docker Hub (base/dev/dist × Java 17/21/25, linux/amd64+arm64). No application code, no tests, no lint.

## Layout

- `Dockerfile17` / `Dockerfile21` / `Dockerfile25` — identical except the 2 `FROM` lines. Stages per file:
  - `base`: `maven:3.9-eclipse-temurin-XX`, app user `bob` (uid/gid 8989), `WORKDIR /app`; persists `DOCKER_USER`/`DOCKER_GROUP` as env vars (needed by `fix-perm.sh` and downstream `COPY --chown`)
  - `dev`: base + `fix-perm.sh` at `/fix-perm.sh`, entrypoint `sleep infinity` (container idles for mounted volumes)
  - `dist`: `eclipse-temurin:XX-jre` only — deliberately no Maven; same `bob` user and env persistence
- `build-and-push.sh` — buildx multi-arch build; optional version arg `17|21|25` builds that version's 3 tags (e.g. `bash build-and-push.sh 21`), no arg builds all 9; `--push` is hardcoded (no dry-run)
- `fix-perm.sh` — UID/GID fixer baked into the dev image; driven by `FIX_UID`/`FIX_GID` env vars; resolves `bob` via the persisted `DOCKER_USER`/`DOCKER_GROUP` env vars and fails fast if they are missing; re-owns only `/app` and `/home/bob` (it must never chown the whole filesystem)
- `.github/state/*.digest` — last-pushed upstream base-image digests; auto-committed by CI as `github-actions[bot]`

## Commands

- Local single-target build:
  `docker build --pull -f Dockerfile21 --target dev -t zcscompany/java:21-dev .`
- Full rebuild + push: `bash build-and-push.sh` — requires Docker Hub login with push rights to `zcscompany/java`; pushes all 9 tags
- One version only: `bash build-and-push.sh 21`

## Gotchas

- Any change to one Dockerfile must be mirrored to the other (they differ only by version)
- User `bob` (uid/gid 8989) is load-bearing for `fix-perm.sh`; keep the fixed ids
- The persisted `ENV DOCKER_USER`/`DOCKER_GROUP` lines in the `base` and `dist` stages are load-bearing for `fix-perm.sh`; never drop them when editing the Dockerfiles
- CI (`.github/workflows/rebuild-java-{17,21,25}.yml`): one workflow per version, run nightly (UTC, 17→00:00, 21→02:00, 25→04:00, 2h apart) + manual dispatch. Each compares its version's 2 upstream digests (skopeo) vs `.github/state/*.digest`; on a change it rebuilds+pushes that version's 3 tags, then commits/pushes the updated digest files as `github-actions[bot]`. Deleting a digest file forces a rebuild. Do not hand-edit or commit digest files.
- CI runners are pinned to `ubuntu-26.04` (deliberate migration ahead of the `ubuntu-latest` rollout, actions/runner-images#14748); do not revert to `ubuntu-latest`
- Pushing builds SBOM + provenance attestations (`--sbom=true --provenance=true`)

## Known issues / backlog

Medium-severity findings from the 2026-09 repo audit, deliberately not fixed yet. Fix in priority order:

1. CI commit/push races (`.github/workflows/rebuild-java-*.yml`):
   - `git commit ... || exit 0` swallows any real commit failure → digests never persist → nightly rebuild loop
   - `git push` without a preceding `git pull --rebase` → two concurrent runs (a manual dispatch overlapping a scheduled run) push non-fast-forward and fail, leaving the digest unpersisted
   - Fix: add a `concurrency:` group keyed on repo+ref, or `git pull --rebase` before `git push`
2. `build-and-push.sh`:
   - unguarded `docker buildx stop container` under `set -e` → exits 1 after a successful push, and leaks the builder on failure — use a `trap` or `|| true`
   - no validation of the version argument: `build-and-push.sh 99` fails cryptically ("Dockerfile99 not found") and arbitrary values would push unexpected tags — add a `case "$v" in 17|21|25) ;; *) usage;; esac` guard
   - `docker buildx create ... || true` discards the real failure cause; consider `docker buildx inspect` first
3. `fix-perm.sh` hardcodes uid/gid `888` for users/groups displaced by `FIX_UID`/`FIX_GID`; can collide if 888 is already taken in the base image (or is the host value) — pick a free id at runtime
4. `fix-perm.sh` still emits shellcheck SC2236 (`! -z`) style warnings

## Improvements to consider

- Matrix/generated CI workflows: the 3 rebuild workflows are ~95 lines each and only differ by version/cron; a matrix or template would prevent per-version drift when adding e.g. Java 26 (new Dockerfile + workflow + 2 digest files)
- Add `timeout-minutes` to the CI jobs (a hung skopeo/push currently can consume the full runner budget)
- Add explicit `docker/setup-qemu-action` and pin buildx in CI so the arm64 legs of `--platform linux/amd64,linux/arm64` do not rely on the runner image having binfmt preinstalled
- Cross-repo consistency:
  - the node repo (`docker-image-node`) persists `DOCKER_USER`/`DOCKER_GROUP` only as ARG and has the same latent `fix-perm.sh` bug fixed here; align it (python already persists them via `ENV`)
  - `bob` is uid/gid 8989 here but 1000 in the node/python repos — the shared "same conventions" story would be stronger if aligned, or at least documented
- Cosmetic: missing trailing newline in the workflow YAMLs and `LICENSE`; trailing whitespace on the `adduser` line (Dockerfile line 11); version list ordering in `build-and-push.sh` (descending) vs README (ascending)