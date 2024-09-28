#!/bin/bash

set -eux 

docker buildx create --name container --driver=docker-container default || true

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target base -t zcscompany/java:21-base .

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target dev -t zcscompany/java:21-dev .

docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true --builder=container --pull --push --target dist -t zcscompany/java:21-dist .

docker buildx stop container
