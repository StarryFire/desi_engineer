#!/usr/bin/bash

# Ref: https://www.jujens.eu/posts/en/2017/Feb/15/docker-unix-socket/

# Quit on error.
set -e
# Treat undefined variables as errors.
set -u

function main {
    local uid="${1:-}"
    local gid="${2:-}"

    # Change the uid
    if [[ -n "${uid:-}" ]]; then
        usermod -u "${uid}" uwsgi
    fi
    # Change the gid
    if [[ -n "${gid:-}" ]]; then
        groupmod -g "${gid}" uwsgi
    fi

    # Setup permissions on the run directory where the sockets will be
    # created, so we are sure the app will have the rights to create them.

    # Make sure the folder exists.
    mkdir /var/run/uwsgi
    # Set owner.
    chown root:uwsgi /var/run/uwsgi
    # Set permissions.
    chmod u=rwX,g=rwX,o=--- /var/run/uwsgi
}

main "$@"