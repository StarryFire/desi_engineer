#!/bin/bash

################################################## PUBLIC ##############################################################################################

deploy() {
    echo_err "[running: deploy $@]"

    _deploy_script_setup $@

    git fetch origin main
    echo_err "[fetched changes from remote.]"

    # Compare the two hashes
    LOCAL_HASH=$(git rev-parse @)
    REMOTE_HASH=$(git rev-parse @{u})

    if [ $(git diff $LOCAL_HASH..$REMOTE_HASH | wc -c) -gt 0 ]; then
        echo_err "[changes detected in the remote repository...]"
        # resetting any local changes in the staging and working directories
        # git add .
        # git reset --hard

        git pull origin main
        echo_err "[remote changes merged.]"

        # make sure this script is run with "set -e" flag set, otherwise the script won't stop at "git pull origin main" when local changes are detected, and the following will reset any local changes
        # removes any folders/files that are now ignored by the updated .gitignore file
        git add .
        files_and_folders_to_remove=$(git status --porcelain | awk '{print $2}')
        if [ "$files_and_folders_to_remove" != "" ]; then
            echo_err -e "[removing the following ignored files/folders]\n$files_and_folders_to_remove"
            git reset --hard
            echo_err "[removed]"
        fi
    else
        echo_err "[no changes in the remote repository.]"
        if [ "$force" == "y" ]; then
            echo_err "[forcing deployment...]"
        else
            exit 0
        fi
    fi

    deploy_script_changed="false"
    if [ $(git diff $LOCAL_HASH..$REMOTE_HASH -- deployment/scripts/aliases/*.sh | wc -c) -gt 0 ]; then
        # notice, we are comparing local changes and not local committed changes, with the remote changes in this case as deployment script might get pulled separately
        deploy_script_changed="true"
    fi

    extra_flags=""
    if [ "$deploy_script_changed" == "true" ]; then
        echo_err "[changes made in the deploy script, running the updated deploy script...]"

        # refresh the aliases so that the deploy function is called with the latest changes
        source deployment/scripts/aliases/global.sh
        load_all_aliases
        if [ "$force" == "n" ]; then
            extra_flags="-f"
        fi
    fi

    # only commands inside this function will be run with the latest changes on the first run of deploy command, if the deploy script was changed while pulling
    _deploy_helper $@ $extra_flags
}

# deploy_nginx() {
#     echo_err "[deploying nginx...]"
#     _copy_nginx_files
#     if $(_dc_is_container_running nginx); then
#         echo_err "[reloading nginx...]"
#         dc_exec docker-gen docker-gen -notify-sighup nginx /etc/docker-gen/templates/custom_nginx.tmpl /etc/nginx/conf.d/default.conf
#         # dc_exec nginx -cmd="nginx -t"
#         # dc_exec nginx -cmd="nginx -s reload"
#         # echo_err "nginx reloaded."
#     else
#         echo_err "[nginx is not running...]"
#         dc_up_build nginx
#     fi
#     echo_err "[nginx deployed successfully.]"
# }

# deploy_cms() {
#     dc_up_build cms

#     cms_container_id=$(_dc_container_id cms)
#     if [ "$cms_container_id" == "" ]; then
#         echo_err "[cms service is not running!]"
#         exit 1
#     fi
#     status=$(_do_container_status $cms_container_id)
#     health_status=$(_do_container_health_status $cms_container_id)
#     while [ "$health_status" == "starting" ]; do
#         health_status=$(_do_container_health_status $cms_container_id)
#         echo_err "[waiting for cms service to start...]"
#         sleep 5s
#     done

#     if [ "$status" == "running" ] && [ "$health_status" == "healthy" ]; then
#         echo_err "[cms service is running.]"
#     else
#         echo_err "[cms service is not running!]"
#         echo_err "[status: $status, health_status: $health_status]"
#         exit 1
#     fi
#     echo_err "[cms deployed successfully.]"
# }

# deploy_auxillary() {
#     echo_err "[deploying auxillary services...]"
#     auxillary_containers=("docker-gen" "acme-companion" "grafana" "prometheus" "cadvisor" "node-exporter" "loki" "promtail" "tailscale" "tailscale-nginx-auth")
#     stopped_containers=()
#     running_containers=()
#     for container in "${auxillary_containers[@]}"; do
#         if [ $(_dc_is_container_running $container) ]; then
#             echo_err "[$container is already running...]"
#             running_containers+=($container)
#         else
#             echo_err "[$container is not running...]"
#             stopped_containers+=($container)
#         fi
#     done

#     if [ ${#running_containers[@]} -gt 0 ]; then
#         dc_up_build "${running_containers[@]}"
#     fi
#     if [ ${#stopped_containers[@]} -gt 0 ]; then
#         dc_up_build "${stopped_containers[@]}"
#     fi

#     echo_err "[auxillary services deployed successfully.]"
# }

################################################## PRIVATE ##############################################################################################

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
    _generate_or_renew_tailscale_host_cert "desi-engineer-1.tail76efa.ts.net"
    _generate_or_renew_cloudflare_host_cert "uptime-kuma.desiengineer.dev"
    echo_err "[successfully generated/renewed private hosts certificates.]"
}

_generate_or_renew_tailscale_host_cert() {
    domain=$1
    echo_err "[generating/renewing certificates for $domain...]"
    # to generate or renew tailscale https certs in /var/lib/tailscale/certs
    dc_exec tailscale tailscale cert \
        --cert-file="/var/lib/tailscale/certs/$domain.crt" \
        --key-file="/var/lib/tailscale/certs/$domain.key" \
        "$domain"
    echo_err "[tailscale certificates generated/renewed successfully for $domain.]"
}

# _generate_or_renew_cloudflare_host_cert "uptime-kuma.desiengineer.dev" --dry-run
_generate_or_renew_cloudflare_host_cert() {
    domain=$1
    extra_args=$2
    do_run --rm -it --name certbot \
        -v "test:/etc/letsencrypt" \
        -v "./deployment/secrets/lets_encrypt:/deployment/secrets/lets_encrypt" \
        certbot/dns-cloudflare certonly -n -m "desiengineer.dev@gmail.com" --agree-tos --no-eff-email \
        --dns-cloudflare --dns-cloudflare-credentials /deployment/secrets/lets_encrypt/cloudflare.ini \
        -d "$domain" $extra_args
}

_deploy_helper() {
    echo_err "[running: _deploy_helper $@]"

    _deploy_script_setup $@

    dc_up
    if [ "$generate_or_renew_certs" == "y" ]; then
        _generate_or_renew_certs
    fi
    # cleanup unused images & containers
    do_cleanup
    echo_err "[deleted stopped containers and unused images.]"

    echo_err "[success.]"

    # cms_changed="false"
    # if [ $(git diff $LOCAL_HASH..$REMOTE_HASH -- . ':!deployment' 'deployment/services/app/cms' | wc -c) -gt 0 ]; then
    #     cms_changed="true"
    # fi

    # nginx_config_changed="false"
    # if [ $(git diff $LOCAL_HASH..$REMOTE_HASH -- deployment/services/proxy/nginx | wc -c) -gt 0 ]; then
    #     nginx_config_changed="true"
    # fi

    # auxillary_changed="false"
    # if [ $(git diff $LOCAL_HASH..$REMOTE_HASH -- 'deployment/services' ':!deployment/services/app/cms' ':!deployment/services/proxy/nginx' | wc -c) -gt 0 ]; then
    #     auxillary_changed="true"
    # fi

    # if [ "$cms_changed" == "true" ] || [ "$force" == "y" ]; then
    #     if [ "$cms_changed" == "true" ]; then
    #         echo_err "[cms changes detected.]"
    #     else
    #         echo_err "[no changes detected in cms.]"
    #     fi
    #     if [ "$force" == "y" ]; then
    #         echo_err "[forcing cms deployment...]"
    #     fi
    #     deploy_cms
    # else
    #     echo_err "[no changes made to cms.]"
    # fi

    # if [ "$auxillary_changed" == "true" ] || [ "$force" == "y" ]; then
    #     if [ "$auxillary_changed" == "true" ]; then
    #         echo_err "[changes detected in auxillary services.]"
    #     else
    #         echo_err "[no changes detected in auxillary services.]"
    #     fi
    #     if [ "$force" == "y" ]; then
    #         echo_err "[forcing auxillary services deployment...]"
    #     fi
    #     deploy_auxillary
    # else
    #     echo_err "[no changes made to auxillary services.]"
    # fi

    # if [ "$generate_or_renew_certs" == "y" ]; then
    #     echo_err "[generating tailscale https certificates...]"
    #     # to generate tailscale https certs in /var/lib/tailscale/certs
    #     dc_exec tailscale tailscale cert \
    #         --cert-file='/var/lib/tailscale/certs/desi-engineer-1.tail76efa.ts.net.crt' \
    #         --key-file='/var/lib/tailscale/certs/desi-engineer-1.tail76efa.ts.net.key' 'desi-engineer-1.tail76efa.ts.net'
    #     echo_err "[tailscale https certificates generated.]"
    # fi

    # if [ "$nginx_config_changed" == "true" ] || [ "$force" == "y" ]; then
    #     if [ "$nginx_config_changed" == "true" ]; then
    #         echo_err "[nginx config changed.]"
    #     else
    #         echo_err "[no changes detected in nginx config.]"
    #     fi
    #     if [ "$force" == "y" ]; then
    #         echo_err "[forcing nginx deployment...]"
    #     fi
    #     deploy_nginx
    # else
    #     echo_err "[no changes made to nginx.]"
    # fi

    # cleanup unused images & containers
    # do_cleanup
    # echo_err "[deleted stopped containers and unused images.]"

    # echo_err "[success.]"

}

_deploy_parse_args() {
    LONGOPTS=generate-or-renew-certs,fresh
    SHORTOPTS=f
    PARSED=$(getopt --options=$SHORTOPTS --longoptions=$LONGOPTS --name "$0" -- "$@")
    eval set -- "$PARSED"
    generate_or_renew_certs=n force=n
    positional_params=()
    while true; do
        case "$1" in
        --generate-or-renew-certs)
            generate_or_renew_certs=y
            shift
            ;;
        -f | --force)
            force=y
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
    shift $((OPTIND - 1))
    positional_params=("$@")
    echo_err "[force is set to $force]"
    echo_err "[generate_or_renew_certs is set to $generate_or_renew_certs]"
}

_deploy_script_setup() {
    _deploy_parse_args $@
}
