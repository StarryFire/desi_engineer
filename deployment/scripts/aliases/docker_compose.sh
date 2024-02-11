#!/bin/bash

############################################################### PUBLIC ################################################################################
dc() {
    docker compose $DOCKER_COMPOSE_FILES $@
}

dc_debug() {
    docker -D compose $DOCKER_COMPOSE_FILES $@
}

dc_build() {
    dc build $@
}
dc_debug_build() {
    # --progress=plain prints out the output of docker image commands to the shell
    # Using with --no-cache ensures that the docker image commands are run every time and hence the output is shown everytime as well
    BUILDKIT_PROGRESS=plain dc_debug build --no-cache $@
}

dc_up_build() {
    _copy_nginx_files
    dc up $@ --build -d --remove-orphans
}

dc_force_up() {
    _copy_nginx_files
    dc up $@ --build -d --remove-orphans --force-recreate
}

dc_up() {
    _copy_nginx_files
    dc up $@ -d --remove-orphans
}
dc_debug_up() {
    _copy_nginx_files
    dc_debug up $@ -d --remove-orphans
}

dc_restart() {
    dc restart $@
}

dc_force_restart() {
    dc_down $@
    dc_up $@
}

dc_force_up_logs() {
    dc_force_up $@
    dc_logs $@
}

dc_logs() {
    dc logs $@ -f
}

dc_exec() {
    dc exec $@
}

dc_enter() {
    dc_exec $@ /bin/sh
}

dc_down() {
    # Run with caution on production!
    # This also destroys the docker bridge networks changing their subnets which are hardcoded into the project in services like grafana!
    dc down $@ --remove-orphans
}

################################################# PRIVATE ##############################################################################################

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
