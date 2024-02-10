# Stage 1
FROM golang:1.21 AS builder

ARG ENV
ARG PLATFORM_LINUX_ARM64="aarch64"
ARG PLATFORM_LINUX_x86_64="x86_64"

WORKDIR /app

# Install deps
COPY go.mod go.mod
COPY go.sum go.sum
# Only the aliases in these files are required to build and install the app
COPY deployment/scripts/aliases/ deployment/scripts/aliases/
COPY Makefile Makefile
RUN make install

COPY . .

# Build the Go app
RUN make build

# SHELL ["/bin/bash", "-c"]
# Or use the below to install and build if you don't want to use makefile
# Change the default shell to bash
# RUN source deployment/scripts/aliases/global.sh && load_all_aliases && install
# RUN source deployment/scripts/aliases/global.sh && load_all_aliases && build

# Stage 2
FROM alpine:latest

# --no-cache 
# tells apk not to cache the index locally. 
# This is often used in Dockerfiles to keep the image size small,
# as it prevents apk from storing a copy of the package index in the image.
# ca-certificates
# This package includes the Certificate Authority certificates that are used to verify SSL/TLS connections.
# This helps docker containers to establish secure SSL/TLS connections to external services
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# All files read by the binary during runtime must be part of the assets directory
COPY --from=builder /app/assets ./assets
COPY --from=builder /app/bin/desi_engineer .

# EXPOSE is used only for the purposes of documenting which ports are intended to be published.
EXPOSE 3000

# Command to run the executable
# By listening on 0.0.0.0, a service can accept connections from any network interface, 
# not just localhost or the container's internal IP address. This is crucial because Docker 
# containers have their own network namespace, and localhost inside a Docker container 
# refers to the container itself, not the Docker host. So, if a service inside a Docker 
# container is supposed to accept connections from outside the container, 
# it needs to listen on 0.0.0.0
CMD ["./desi_engineer", "serve", "--host", "0.0.0.0", "--port", "3000"]

