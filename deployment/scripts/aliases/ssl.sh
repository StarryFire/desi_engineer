#!/bin/bash

_generate_or_renew_certs() {
    _generate_or_renew_private_host_certs
    _generate_or_renew_public_host_certs
    _refresh_nginx_config_files
}

_generate_or_renew_public_host_certs() {
    echo "TODO"
}

_generate_or_renew_private_host_certs() {
    echo_err "[generating/renewing private hosts certificates...]"
    _generate_or_renew_tailscale_host_cert "desi-engineer-1.tail76efa.ts.net" "private_nginx_certs" tailscale_lib
    _generate_or_renew_cloudflare_host_cert "uptime-kuma.desiengineer.dev" "private_nginx_certs" lets_encrypt_etc
    echo_err "[successfully generated/renewed private hosts certificates.]"
}


# link paths should be relative to where the link file is created
copy_x_to_nginx_certs() {
    local host=$1
    local file_type=$2
    local path_to_file_or_link=$3
    local link_file=$4
    local nginx_volume_mount=$5

    mkdir -p $nginx_volume_mount/$host

    actual_file=./$host/$file_type.pem # using relative path for symbolic link as absolute path doesn't fit our use-case
    if [ ! -L $link_file ]; then
        ln -s $actual_file $link_file;
    fi

    if [ -f $path_to_file_or_link ]; then
        make_changes="true";
        if [ -f $link_file ]; then
            # checks whether $path_to_file_or_link's timestamp is newer than $link_file
            # if $path_to_file_or_link/$link_file are links, then the links are first dereferenced and the files that were being pointed to, are compared instead.
            if [ $path_to_file_or_link -nt $link_file ]; then
                echo_err "[renewing $file_type in nginx for $host]";
            else
                echo_err "[no changes in $file_type in nginx for $host]";
                make_changes="false";
            fi
        else
            echo_err "[generating $file_type in nginx for $host]";
        fi

        if [ $make_changes == "true" ]; then
            # changing current directory to the directory relative to which the symbolic link paths were created, 
            # so that readlink -f can correctly follow the
            # symbolic links and give us the correct target_path
            cd $nginx_volume_mount 
            target_path=$(readlink -f $link_file)
            cp $path_to_file_or_link $target_path;
        fi
    fi
}

copy_dhparam_key_to_nginx_certs() {
    local host=$1
    local nginx_volume_mount=$2

    global_dhparam_file_path=$nginx_volume_mount/dhparam.pem
    if [ ! -f $global_dhparam_file_path ]; then
        openssl dhparam -out $global_dhparam_file_path 2048;
    fi
    copy_x_to_nginx_certs $host dhparam $global_dhparam_file_path $nginx_volume_mount/$host.dhparam.pem $nginx_volume_mount
}


# _generate_or_renew_tailscale_host_cert "desi-engineer-1.tail76efa.ts.net" "private_nginx_certs" tailscale_lib
_generate_or_renew_tailscale_host_cert() {
    host=$1
    nginx_certs_volume=$2
    tailscale_certs_volume=$3
    nginx_volume_mount=/nginx_certs
    tailscale_volume_mount=/tailscale_certs

    echo_err "[generating/renewing tailscale certificates for $host...]"

    # to generate or renew tailscale https certs in /var/lib/tailscale/certs/... (actual files, not links)
    dc_exec tailscale tailscale cert \
        --cert-file="/var/lib/tailscale/certs/$host.crt" \
        --key-file="/var/lib/tailscale/certs/$host.key" \
        "$host"
    
    docker run --name ssl-utility --rm \
    -v $tailscale_certs_volume:$tailscale_volume_mount -v $nginx_certs_volume:$nginx_volume_mount -v ./deployment/scripts/aliases:/deployment/scripts/aliases \
    bash:latest bash -c '
    source /deployment/scripts/aliases/global.sh
    load_all_aliases
    _debug

    apk update
    apk add openssl

    host=$1
    nginx_volume_mount=$2
    tailscale_volume_mount=$3
    
    # copying tailscale certs for host if they exist
    copy_x_to_nginx_certs $host fullchain $tailscale_volume_mount/certs/$host.crt $nginx_volume_mount/$host.crt $nginx_volume_mount;
    copy_x_to_nginx_certs $host key $tailscale_volume_mount/certs/$host.key $nginx_volume_mount/$host.key $nginx_volume_mount;
    copy_dhparam_key_to_nginx_certs $host $nginx_volume_mount;
    ' _ $host $nginx_volume_mount $tailscale_volume_mount
    echo_err "[tailscale certificates generated/renewed successfully for $host.]"
}

# _generate_or_renew_cloudflare_host_cert "uptime-kuma.desiengineer.dev" "private_nginx_certs" lets_encrypt_etc
_generate_or_renew_cloudflare_host_cert() {
    host=$1
    nginx_certs_volume=$2
    lets_encrypt_certs_volume=$3
    nginx_volume_mount=/nginx_certs
    lets_encrypt_volume_mount=/tailscale_certs

    echo_err "[generating/renewing letsencrypt certificates for $host...]"

    # to generate or renew letsencrypt certificates in /etc/letsencrypt/live/$host/... (links) and /etc/letsencrypt/archive/$host/... (actual files)
    do_run --rm -it --name certbot \
        -v "lets_encrypt_etc:/etc/letsencrypt" \
        -v "./deployment/secrets/lets_encrypt:/deployment/secrets/lets_encrypt" \
        certbot/dns-cloudflare certonly -n -m "desiengineer.dev@gmail.com" --agree-tos --no-eff-email \
        --dns-cloudflare --dns-cloudflare-credentials /deployment/secrets/lets_encrypt/cloudflare.ini \
        -d "$host"

    docker run --name ssl-utility --rm \
    -v $lets_encrypt_certs_volume:$lets_encrypt_volume_mount -v $nginx_certs_volume:$nginx_volume_mount -v ./deployment/scripts/aliases:/deployment/scripts/aliases \
    bash:latest bash -c '
    source /deployment/scripts/aliases/global.sh
    load_all_aliases
    _debug

    apk update
    apk add openssl

    host=$1
    nginx_volume_mount=$2
    lets_encrypt_volume_mount=$3
    
    # copying letsencrypt certs for host if they exist
    copy_x_to_nginx_certs $host chain $lets_encrypt_volume_mount/live/$host/chain.pem $nginx_volume_mount/$host.chain.pem $nginx_volume_mount;
    copy_x_to_nginx_certs $host fullchain $lets_encrypt_volume_mount/live/$host/fullchain.pem $nginx_volume_mount/$host.crt $nginx_volume_mount;
    copy_x_to_nginx_certs $host key $lets_encrypt_volume_mount/live/$host/privkey.pem $nginx_volume_mount/$host.key $nginx_volume_mount;
    copy_dhparam_key_to_nginx_certs $host $nginx_volume_mount;
    ' _ $host $nginx_volume_mount $lets_encrypt_volume_mount

    echo_err "[letsencrypt certificates generated/renewed successfully for $host.]"
}
# _test_generate_or_renew_cloudflare_host_cert "uptime-kuma.desiengineer.dev"
_test_generate_or_renew_cloudflare_host_cert() {
    host=$1
    extra_args=$2
    do_run --rm -it --name certbot \
        -v "lets_encrypt_etc:/etc/letsencrypt" \
        -v "./deployment/secrets/lets_encrypt:/deployment/secrets/lets_encrypt" \
        certbot/dns-cloudflare certonly -n -m "desiengineer.dev@gmail.com" --agree-tos --no-eff-email \
        --dns-cloudflare --dns-cloudflare-credentials /deployment/secrets/lets_encrypt/cloudflare.ini \
        -d "$host" --dry-run
}
