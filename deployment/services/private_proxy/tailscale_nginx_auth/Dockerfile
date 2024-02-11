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

# # Copy the script.
# Setting the uid and gid of the socket to that of the nginx worker process in the nginx container
# You can get it by running:
# - ps aux: will give the username of the process that owns the nginx worker process i.e. nginx
# - id nginx: will give the uid and gid of the username nginx
# COPY deployment/scripts/set_uid_and_gid.sh /
# RUN bash /set_uid_and_gid.sh "101" "101"
# RUN addgroup -g 101 nginx 
# RUN adduser -u 101 -G nginx -S nginx

RUN apk add rpm
COPY --from=builder /root/tailscale-1.58.2/cmd/nginx-auth/tailscale-nginx-auth.rpm .
RUN rpm -i tailscale-nginx-auth.rpm

# The mounted volume should already belong to nginx for this to work i.e. the host volume should be owned by user id of nginx i.e. 101
USER nginx
CMD [ "/bin/sh", "-c", "/usr/sbin/tailscale.nginx-auth --sockpath='/run/tailscale.nginx-auth/tailscale.nginx-auth.sock'" ]

# USER root
# CMD [ "ls", "-ln", "/nginx/" ]
# CMD [ "/bin/sh", "-c", "/usr/sbin/tailscale.nginx-auth --sockpath='/run/tailscale.nginx-auth/tailscale.nginx-auth.sock'" ]

