#!/bin/bash

############################################################### PUBLIC ################################################################################
dc() {
    docker compose $DOCKER_COMPOSE_FILES $@
}
dc_debug() {
    docker -D compose $DOCKER_COMPOSE_FILES $@
}

# only creates the containers
dc_create() {
    dc up $@ --no-start --no-deps -d --remove-orphans
    _post_create
}
dc_debug_create() {
    dc_debug up $@ --no-start --no-deps -d --remove-orphans
    _post_debug_create
}

dc_build() {
    dc build $@
}
dc_debug_build() {
    # --progress=plain prints out the output of docker image commands to the shell
    # Using with --no-cache ensures that the docker image commands are run every time and hence the output is shown everytime as well
    BUILDKIT_PROGRESS=plain dc_debug build --no-cache $@
}

# Will always build as this step is needed to properly configure the containers before starting them
dc_up() {
    dc_create $@ --build
    dc up $@ -d --remove-orphans
    _post_up
}
dc_debug_up() {
    dc_debug_create $@ --build
    dc_debug up $@ -d --remove-orphans
    _post_up
}


dc_refresh() {
    dc_up $@ --force-recreate
}

dc_restart() {
    dc restart $@
}

dc_down() {
    dc down $@ --remove-orphans
}

dc_down_up() {
    dc_down $@
    dc_up $@
}

dc_logs() {
    dc logs $@ -f
}
dc_error_logs() {
    dc_logs $@ 1>/dev/null
}
dc_stdout_logs() {
    dc_logs $@ 2>/dev/null
}

dc_refresh_logs() {
    dc_refresh $@
    dc_logs $@
}


dc_exec() {
    dc exec $@
}
# Only works with running containers
# dc_view_file private-nginx /etc/nginx/conf.d/default.conf
dc_view_file() {
    dc_exec $1 cat $2
}

# creates a new container and runs a shell in it
dc_run_enter() {
    dc run --entrypoint="/bin/sh" $1
}

dc_enter() {
    dc_exec $@ /bin/sh
}

# make sure to uncomment the mirror directive in nginx config before running this
dc_show_nginx_upstream_requests() {
    # Install netcat inside the container
    dc_exec private-nginx apt-get update
    dc_exec private-nginx apt-get install netcat-openbsd

    # Run netcat
    dc_exec private-nginx nc -kl 6677 > /dev/stdout
}


################################################# PRIVATE ##############################################################################################

_post_create() {
    _copy_nginx_files
    _copy_private_nginx_files
}
_post_debug_create() {
    _copy_nginx_files
    _copy_private_nginx_files
}

_post_up() {
    _refresh_nginx_config_files
}

_refresh_nginx_config_files() {
    dc_exec public-docker-gen docker-gen -notify-sighup public-nginx /etc/docker-gen/templates/default.conf.dtmpl /etc/nginx/conf.d/default.conf
    dc_exec private-docker-gen docker-gen -notify-sighup private-nginx /etc/docker-gen/templates/default.conf.dtmpl /etc/nginx/conf.d/default.conf
}

# WARNING: Do not call before ensuring that the required volumes are created
_copy_nginx_files() {
    do_volume_rsync ./deployment/services/nginx/public/vhost.d public_nginx_vhostd
}
# WARNING: Do not call before ensuring that the required volumes are created
_copy_private_nginx_files() {
    do_volume_rsync ./deployment/services/nginx/private/vhost.d private_nginx_vhostd
}

_dc_remove_all_stopped_containers() {
    dc rm -f
}

_dc_get_running_services() {
    dc ps --format '{{.Names}}'
}

_dc_is_container_running() {
    _dc_get_running_services | grep -xq $1
}

_dc_container_id() {
    dc ps -q $1
}

# NOTE
# https://unix.stackexchange.com/a/305361
# xyz() {...} / function xyz() {...}
# Curly brace functions will run within the calling shell process, unless they need their own subshell which is:
# - when you run them in the background with &
# - when you run them as a link in a pipeline
#
# xyz() (...) / function xyz() (...)
# If you define the function with parentheses instead of curlies, it will always run in a new process.
#
# SO ALWAYS DEFINE ENTRY POINT FUNCTIONS USING paranthesis!

# This is deliberately defined using curlies as we want this to run inside the calling shell and not a new subshell
# _dc_parse_args() {
#     # LONGOPTS=file:,verbose
#     # SHORTOPTS=f:v
#     LONGOPTS=verbose,command:
#     SHORTOPTS=v,cmd:
#     PARSED=$(getopt --options=$SHORTOPTS --longoptions=$LONGOPTS --name "$0" -- "$@")
#     eval set -- "$PARSED"
#     verbose=n files=() command=""
#     positional_params=()
#     while true; do
#         case "$1" in
#             -v|--verbose)
#                 verbose=y
#                 shift
#             ;;
#             # -f|--file)
#             #     files+=$(printf -- "-f %s " "$2")
#             #     shift 2
#             #     ;;
#             -cmd|--command)
#                 command=$2
#                 shift 2
#             ;;
#             --)
#                 shift
#                 break
#             ;;
#             *)
#                 echo_err "Programming error"
#                 exit 3
#             ;;
#         esac
#     done

#     # files=${files::-1} # Remove the trailing separator

#     shift $((OPTIND -1))
#     positional_params=("$@")

#     containers=${positional_params[@]}
# }

# This is deliberately defined using curlies as we want this to run inside the calling shell and not a new subshell
# _dc_script_setup() {
#     _dc_parse_args $@
# }
