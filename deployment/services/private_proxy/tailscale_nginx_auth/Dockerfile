FROM golang:1.21 AS builder

ARG PLATFORM_LINUX_ARM64="aarch64"
ARG PLATFORM_LINUX_x86_64="x86_64"

WORKDIR /root/
RUN curl -sLO https://github.com/tailscale/tailscale/archive/refs/tags/v1.58.2.tar.gz
RUN tar -xvf v1.58.2.tar.gz
RUN cd tailscale-1.58.2/cmd/ && go install ./mkpkg
RUN cd tailscale-1.58.2/cmd/nginx-auth/ && ./mkdeb.sh

# TODO: Make this platform agnostic like the cms container image
RUN if [ "$(uname --machine)" = "$PLATFORM_LINUX_ARM64" ]; then \
    cp /root/tailscale-1.58.2/cmd/nginx-auth/tailscale-nginx-auth-0.1.3-arm64.rpm /root/tailscale-1.58.2/cmd/nginx-auth/tailscale-nginx-auth.rpm; \
    echo "file copied for $PLATFORM_LINUX_ARM64"; \
    elif [ "$(uname --machine)" = "$PLATFORM_LINUX_x86_64" ]; then \
    cp /root/tailscale-1.58.2/cmd/nginx-auth/tailscale-nginx-auth-0.1.3-amd64.rpm /root/tailscale-1.58.2/cmd/nginx-auth/tailscale-nginx-auth.rpm; \
    echo "file copied for $PLATFORM_LINUX_x86_64"; \
    else \
    echo "machine not supported"; \
    exit 1; \
    fi

# Stage 2
FROM alpine:latest

ARG NGINX_UID=103
ARG NGINX_GID=103

# # Copy the script.
# Setting the uid and gid of the socket to that of the nginx worker process in the nginx container
# You can get it by running the following in the nginx container:
# - ps aux: will give the username of the process that owns the nginx worker process i.e. nginx
# - id nginx: will give the uid and gid of the username nginx

RUN apk add rpm
COPY --from=builder /root/tailscale-1.58.2/cmd/nginx-auth/tailscale-nginx-auth.rpm .
RUN rpm -i tailscale-nginx-auth.rpm

RUN mkdir -p /run/tailscale.nginx-auth/

# The directory (/run/tailscale.nginx-auth) should belong to the nginx-worker userid and groupid so that it can access the socket
RUN addgroup -g $NGINX_GID nginx
RUN adduser -u $NGINX_UID -G nginx -S nginx
RUN chown -R nginx:nginx /run/tailscale.nginx-auth

USER nginx
CMD [ "/bin/sh", "-c", "/usr/sbin/tailscale.nginx-auth --sockpath='/run/tailscale.nginx-auth/tailscale.nginx-auth.sock'" ]
