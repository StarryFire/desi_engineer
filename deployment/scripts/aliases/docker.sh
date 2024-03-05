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
        _do_prune_volumes -v
    else
        _do_prune_containers
        _do_prune_images
        _do_prune_volumes
    fi
}

# WARNING!! Use with caution!!
# Removes:
# - all stopped containers
# - all unused networks
# - all unused images
# - all build cache
# - all unused anonymous and named volumes
do_complete_cleanup() {
    docker system prune -a
    docker volume prune -a
}

do_run() {
    docker run $@
}

# Run this to copy data from host to volume or from volume to volume
# Example: do_volume_cp ./deployment/services/proxy/nginx/vhost.d private_nginx_vhostd
do_volume_cp() {
    readarray -d ':' -t from < <(printf "%s" $1)
    source_resource="${from[0]}" # volume or directory on host
    source_path="/from"          # absolute path to source inside source_resource
    if [ ${#from[@]} -eq 2 ]; then
        source_path+="${from[1]}"
    elif [ ${#from[@]} -eq 1 ]; then
        source_path+='/.'
    else
        exit 1
    fi

    readarray -d ':' -t to < <(printf "%s" $2)
    destination_resource="${to[0]}" # volume or directory on host
    destination_path="/to"          # absolute path to destination inside destination_resource
    if [ ${#to[@]} -eq 2 ]; then
        destination_path+="${to[1]}"
    elif [ ${#to[@]} -eq 1 ]; then
        destination_path+=''
    else
        exit 1
    fi

    destination_parentdir="$(dirname $destination_path)"
    if [ "$destination_parentdir" == "/" ]; then
        destination_parentdir="/to"
    fi

    cmd=""
    # do not attempt to create /to since it already exists
    if [ "$destination_parentdir" != "/to" ]; then
        cmd+="mkdir -p $destination_parentdir && "
    fi
    cmd+="cp -r $source_path $destination_path"

    set -x
    docker run --name volume-copy-utility --rm -v $source_resource:/from -v $destination_resource:/to \
        busybox sh -c "$cmd"
    set +x
}

# do_volume_rsync lets_encrypt_etc:/live/. test:/x
do_volume_rsync() {
    readarray -d ':' -t from < <(printf "%s" $1)
    source_resource="${from[0]}" # volume or directory on host
    source_path="/from"          # absolute path to source inside source_resource
    if [ ${#from[@]} -eq 2 ]; then
        source_path+="${from[1]}"
    elif [ ${#from[@]} -eq 1 ]; then
        source_path+='/.'
    else
        exit 1
    fi

    readarray -d ':' -t to < <(printf "%s" $2)
    destination_resource="${to[0]}" # volume or directory on host
    destination_path="/to"          # absolute path to destination inside destination_resource
    if [ ${#to[@]} -eq 2 ]; then
        destination_path+="${to[1]}"
    elif [ ${#to[@]} -eq 1 ]; then
        destination_path+=''
    else
        exit 1
    fi

    destination_parentdir="$(dirname $destination_path)"
    if [ "$destination_parentdir" == "/" ]; then
        destination_parentdir="/to"
    fi

    cmd=""
    # do not attempt to create /to since it already exists
    if [ "$destination_parentdir" != "/to" ]; then
        cmd+="mkdir -p $destination_parentdir && "
    fi
    # do not delete the /to itself since it is mounted against the destination_resource
    if [ "$destination_path" != "/to" ]; then
        cmd+="rm -rf $destination_path && "
    else
        cmd+="rm -rf /to/* && "
    fi
    cmd+="cp -r $source_path $destination_path"

    set -x
    docker run --name volume-copy-utility --rm -v $source_resource:/from -v $destination_resource:/to \
        busybox sh -c "$cmd"
    set +x
}

# Run this to delete data from volume
do_volume_rm() {
    readarray -d ':' -t resource < <(printf "%s" $1)
    resource="${resource[0]}" # volume or directory on host
    resource_path='/resource' # absolute path to the file/directory inside resource
    if [ ${#resource[@]} -eq 2 ]; then
        resource_path+="${resource[1]}"
    elif [ ${#resource[@]} -eq 1 ]; then
        resource_path+='/*'
    else
        exit 1
    fi
    docker run --name volume-rm-utility --rm -v $resource:/resource busybox sh -c "rm -rf $resource_path"
}

# do_volume_inspect lets_encrypt_etc
do_volume_inspect() {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    set -x
    sudo ls -l /var/lib/docker/volumes/$1/_data
    set +x
}
# do_volume_mount lets_encrypt_etc
do_volume_mount() {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    docker run --name volume-mount-utility --rm -it -v $1:/$1 -w /$1 busybox sh
}
do_volume_ls() {
    docker volume ls --format '{{ json . }}' | jq -c
}
# prints out size of each volume and the number of containers each volume is linked to
do_volume_sizes() {
    docker system df -v | sed -n '/VOLUME NAME/,/^ *$/p'
}

# do_volume_backup volume_to_backup destination_full_filename
# do_volume_backup uptime_kuma_data /tmp/uptime_kuma_data.tar.gz
do_volume_backup() {
    touch $2
    docker run --rm \
        -v $1:/backup-volume \
        -v $2:/backup.tar.gz \
        busybox \
        tar -zcvf /backup/backup.tar.gz -C /backup-volume/ .
}

# do_volume_restore backup_full_filename volume_to_restore
# do_volume_backup /tmp/uptime_kuma_data.tar.gz uptime_kuma_data
do_volume_restore() {
    docker run --rm \
        -v $1:/restore-volume \
        -v $2:/restore.tar.gz \
        busybox \
        tar -zxvf /restore.tar.gz -C /restore-volume
}

do_rm_volume() {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    docker volume rm $1
}

# creates a new container and runs a shell in it
do_enter() {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    do_run --entrypoint="/bin/sh" -it $1
}

# Works with both running and stopped containers
# do_view_file private-nginx /etc/nginx/conf.d/default.conf
do_view_file() {
    if [ $# -ne 2 ]; then
        exit 1
    fi
    docker cp $1:$2 - | tar x -O
}
# do_view_file_in_vim private-nginx /etc/nginx/conf.d/default.conf
do_view_file_in_vim() {
    docker cp $1:$2 - | tar x -O | vi -
}

# do_get_docker_network_bridge_name private-1
do_get_docker_network_bridge_name() {
    network_id=$(docker network inspect -f {{.Id}} $1)
    echo "br-${network_id:0:12}"
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

_do_prune_volumes() {
    _do_script_setup $@
    # removes all unused anonymous volumes
    if [ "$verbose" == "y" ]; then
        do_debug volume prune -f
    else
        docker volume prune -f
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
