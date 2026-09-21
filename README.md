# ZCS Java docker images

Docker images used for ZCS Java applications.

## Why a custom image?

ZCS applications standardize on their own runtime images instead of using the upstream ones directly, so that every technology shares the same conventions:

- **Non-root user `bob`**: containers run as the `bob` user (never `root`), with predictable uid/gid across images built from different base distributions.
- **A fix-perm script**: the `dev` image ships `/fix-perm.sh`, which re-aligns `bob`'s uid/gid to the developer's local user, so files and directories bind-mounted from the host keep the developer's ownership while running in the container.
- **`/app` as working directory**: every image works in `/app`, and mounted source code lives there.
- **Three flavours**: `base`, `dev` and `dist` provide the same mental model across projects, regardless of the underlying technology.

ZCS Java docker images come in three flavours:

- `base`: base image, mainly used by other stages
- `dev`: image for local development
- `dist`: image for application distribution

Supported Java versions:

- `Java 17`
- `Java 21`
- `Java 25`

Supported platforms:

- `linux/amd64`
- `linux/arm64`

## Build images

### Base image

```bash
docker build --pull -f Dockerfile21 --target base -t zcscompany/java:21-base .
```

### Dev image

```bash
docker build --pull -f Dockerfile21 --target dev -t zcscompany/java:21-dev .
```

### Dist image

```bash
docker build --pull -f Dockerfile21 --target dist -t zcscompany/java:21-dist .
```

## Release

`./build-and-push.sh` builds and pushes all supported versions (`Java 17/21/25`) for `linux/amd64` and `linux/arm64` to Docker Hub. It requires `docker login`. Use `./build-and-push.sh <17|21|25>` to release a single version's 3 tags.

The images are also rebuilt and pushed automatically by CI whenever the upstream `maven:3.9-eclipse-temurin-*` and `eclipse-temurin:*-jre` base images change.

## Related projects

The same conventions are applied to the other ZCS runtimes:

- [docker-image-python](https://github.com/zcsadmin/docker-image-python) — ZCS Python docker images
- [docker-image-node](https://github.com/zcsadmin/docker-image-node) — ZCS Node docker images

## License

This code is released under the [MIT License](LICENSE).

## Docker hub repository

https://hub.docker.com/r/zcscompany/java

## Support

This code has been developed and released by Laboratorio della Follia, an R&D division of Zucchetti Centro Sistemi.

For support contact Michele Mondelli ([m.mondelli@zcscompany.com](mailto:m.mondelli@zcscompany.com)) or Claudio Cavina ([c.cavina@zcscompany.com](mailto:c.cavina@zcscompany.com)).