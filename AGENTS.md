# AGENTS.md

Docker image builder repo for `zcscompany/java` images on Docker Hub (base/dev/dist × Java 17/21/25, linux/amd64+arm64). No application code, no tests, no lint.

## Layout

- `Dockerfile17` / `Dockerfile21` / `Dockerfile25` — identical except the 2 `FROM` lines. Stages per file:
  - `base`: `maven:3.9-eclipse-temurin-XX` + app user `bob` (uid/gid 8989), `WORKDIR /app`
  - `dev`: base + `fix-perm.sh` at `/fix-perm.sh`, entrypoint `sleep infinity` (container idles for mounted volumes)
  - `dist`: `eclipse-temurin:XX-jre` only — deliberately no Maven
- `build-and-push.sh` — buildx multi-arch build; optional version arg `17|21|25` builds that version's 3 tags (e.g. `bash build-and-push.sh 21`), no arg builds all 9; `--push` is hardcoded (no dry-run)
- `fix-perm.sh` — runtime UID/GID fixer baked into dev image; driven by `FIX_UID`/`FIX_GID` env vars; depends on the fixed 8989 uid/gid
- `.github/state/*.digest` — last-pushed upstream base-image digests; auto-committed by CI as `github-actions[bot]`

## Commands

- Local single-target build:
  `docker build --pull -f Dockerfile21 --target dev -t zcscompany/java:21-dev .`
- Full rebuild + push: `bash build-and-push.sh` — requires Docker Hub login with push rights to `zcscompany/java`; pushes all 9 tags
- One version only: `bash build-and-push.sh 21`

## Gotchas

- Any change to one Dockerfile must be mirrored to the other (they differ only by version)
- User `bob` (uid/gid 8989) is load-bearing for `fix-perm.sh`; keep the fixed ids
- CI (`.github/workflows/rebuild-java-{17,21,25}.yml`): one workflow per version, run nightly (UTC, 17→00:00, 21→02:00, 25→04:00, 2h apart) + manual dispatch. Each compares its version's 2 upstream digests (skopeo) vs `.github/state/*.digest`; on a change it rebuilds+pushes that version's 3 tags, then commits/pushes the updated digest files as `github-actions[bot]`. Deleting a digest file forces a rebuild. Do not hand-edit or commit digest files.
- CI runners are pinned to `ubuntu-26.04` (deliberate migration ahead of the `ubuntu-latest` rollout, actions/runner-images#14748); do not revert to `ubuntu-latest`
- Pushing builds SBOM + provenance attestations (`--sbom=true --provenance=true`)
