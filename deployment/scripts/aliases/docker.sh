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

do_enter() {
    docker run -it $1 /bin/bash
}

#############################################################  PRIVATE  ##################################################################################

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
