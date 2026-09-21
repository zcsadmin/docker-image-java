#!/bin/bash

PUSH="--push"

set -eux

VERSIONS=("$@")
if [ ${#VERSIONS[@]} -eq 0 ]; then
    VERSIONS=(25 21 17)
fi

docker buildx create --name container --driver=docker-container default || true

for v in "${VERSIONS[@]}"; do
    docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull ${PUSH} --target base -f Dockerfile${v} -t zcscompany/java:${v}-base .
    docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull ${PUSH} --target dev -f Dockerfile${v} -t zcscompany/java:${v}-dev .
    docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull ${PUSH} --target dist -f Dockerfile${v} -t zcscompany/java:${v}-dist .
done

docker buildx stop container