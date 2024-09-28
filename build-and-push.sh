#!/bin/bash

set -eux 

docker buildx create --name container --driver=docker-container default || true

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target base -f Dockerfile21 -t zcscompany/java:21-base .

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target dev -f Dockerfile21 -t zcscompany/java:21-dev .

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target dist -f Dockerfile21 -t zcscompany/java:21-dist .

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target base -f Dockerfile17 -t zcscompany/java:17-base .

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target dev -f Dockerfile17 -t zcscompany/java:17-dev .

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target dist -f Dockerfile17 -t zcscompany/java:17-dist .

docker buildx stop container
