FROM nginx:latest

ARG NGINX_UID=103
ARG NGINX_GID=103

RUN usermod -u $NGINX_UID -o nginx
RUN groupmod -g $NGINX_GID -o nginx