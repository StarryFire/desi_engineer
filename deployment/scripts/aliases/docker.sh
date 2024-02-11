#!/bin/bash

########################################################### PUBLIC ####################################################################################

do_debug() {
    docker -D $@
}

do_build() {
    _do_script_setup $@

    if [ "$verbose" == "y" ]; then
        echo_err "running: do_debug build --progress=plain --no-cache ."
        # --progress=plain prints out the output of docker image commands to the shell
        # --no-cache ensures that the docker image commands are run every time and hence the output is shown everytime as well
        do_debug build --progress=plain --no-cache .
    else
        docker build .
    fi

}

do_cleanup() {
    _do_script_setup $@

    if [ "$verbose" == "y" ]; then
        _do_prune_containers -v
        _do_prune_images -v
    else
        _do_prune_containers
        _do_prune_images
    fi
}

do_run() {
    docker run $@
}

# Run this to copy data from host to volume or from volume to volume
# Example: do_volume_cp ./deployment/services/proxy/nginx/vhost.d private_nginx_vhostd 
do_volume_cp() {
    from=$1
    to=$2
    docker run --name copy-utility --rm -v $from:/from -v $to:/to busybox cp -r /from/. /to
}
do_volume_rsync() {
    from=$1
    to=$2
    docker run --name rsync-utility --rm -v $from:/from -v $to:/to busybox sh -c "rm -rf /to/* && cp -r /from/. /to"
}

# Run this to delete data from volume
do_volume_rm() {
    docker run --name remove-utility --rm -v $1:/to_be_removed busybox sh -c "rm -rf to_be_removed/$2"
}
# because we can't pass "*" as an argument to a bash command without the shell automatically expanding it
do_volume_rm_all() {
    docker run --name remove-utility --rm -v $1:/to_be_removed busybox sh -c "rm -rf /to_be_removed/*"
}

do_inspect_volume() {
    set -x
    sudo ls -l /var/lib/docker/volumes/$1/_data
    set +x
}

do_rm_volume() {
    docker volume rm $1
}

# creates a new container and runs a shell in it
do_enter() {
    do_run --entrypoint="/bin/sh" -it $1
}

do_view_file() {
    docker cp $1:$2 - | tar x -O
}

do_view_file_in_vim() {
    docker cp $1:$2 - | tar x -O | vi -
}

#############################################################  PRIVATE  ##################################################################################

_do_check_file_exists() {
    docker exec -it $1 sh -c 'test -f $2'
}

_do_prune_images() {
    _do_script_setup $@
    # removes all unused images that haven't been used for more than 1h
    if [ "$verbose" == "y" ]; then
        do_debug image prune -a -f --filter 'until=1h'
    else
        docker image prune -a -f --filter 'until=1h'
    fi
}

_do_prune_containers() {
    _do_script_setup $@
    # removes all stopped containers that have been stopped for more than 1h, to avoid loss of logs for containers that failed to startup properly
    if [ "$verbose" == "y" ]; then
        do_debug container prune -f --filter 'until=1h'
    else
        docker container prune -f --filter 'until=1h'
    fi
}

_do_container_status() {
    docker inspect --format "{{.State.Status}}" $1
}

_do_container_health_status() {
    docker inspect --format "{{.State.Health.Status}}" $1
}

################################################ ARG/FLAGS PARSING ###############################################################################################
# This is deliberately defined using curlies as we want this to run inside the calling shell and not a new subshell
_do_parse_args() {
    LONGOPTS=verbose
    SHORTOPTS=v
    PARSED=$(getopt --options=$SHORTOPTS --longoptions=$LONGOPTS --name "$0" -- "$@")
    eval set -- "$PARSED"
    verbose=n
    positional_params=()
    while true; do
        case "$1" in
        -v | --verbose)
            verbose=y
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo_err "Programming error"
            exit 3
            ;;
        esac
    done

    # files=${files::-1} # Remove the trailing separator

    shift $((OPTIND - 1))
    positional_params=("$@")

    containers=${positional_params[@]}

}

# This is deliberately defined using curlies as we want this to run inside the calling shell and not a new subshell
_do_script_setup() {

    _do_parse_args $@
}

###############################################################################################################################################
