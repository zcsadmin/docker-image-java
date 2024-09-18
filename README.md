# ZCS Java docker images

Docker images used for ZCS Java applications.

## Example usage

ZCS Java docker images come in three flavours:
- `base`: base image, mainly used by other stages
- `dev`: image for local development
- `dist`: image for application distribution


## Build images

### Base image

```bash
docker build --pull --target base -t zcscompany/java:21-base .
```

### Dev image

```bash
docker build --pull --target dev -t zcscompany/java:21-dev .
```

### Dist image

```bash
docker build --pull --target dist -t zcscompany/java:21-dist .
```

## Docker hub repository

https://hub.docker.com/r/zcscompany/java


## Support

[Madnesslab Team @ Zucchetti Centro Sistemi](mailto:madnesslab@zcscompany.com)

