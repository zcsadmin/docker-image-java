#
# Base image
#
FROM maven:3.9-eclipse-temurin-21 AS base

ARG DOCKER_USER=bob
ARG DOCKER_GROUP=bob

# Add normal user that will use the container
RUN set -ex; addgroup --gid 8989 ${DOCKER_GROUP} && \
    adduser --ingroup ${DOCKER_GROUP} --uid 8989 --disabled-password ${DOCKER_USER} 

# Create app directory
RUN mkdir /app && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /app

# Set working directory
WORKDIR /app

# Run as normal user
USER ${DOCKER_USER}


#
# Dev image
#
FROM base AS dev

# Add fix-perm.sh script to image
USER 0
COPY ./fix-perm.sh /fix-perm.sh
RUN chmod +x /fix-perm.sh

USER ${DOCKER_USER}

# Set entrypoint so the container will run without doing anything
ENTRYPOINT ["/bin/sleep", "infinity"]


#
# Dist image
#
FROM eclipse-temurin:21-jre AS dist

ARG DOCKER_USER=bob
ARG DOCKER_GROUP=bob

# Add normal user that will use the container
RUN set -eux; groupadd --gid 8989 ${DOCKER_GROUP} && \
    useradd --gid ${DOCKER_GROUP} --uid 8989 -m -N ${DOCKER_USER}

# Create app directory
RUN mkdir /app && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /app

# Set working directory
WORKDIR /app

# Run as normal user
USER ${DOCKER_USER}