#!/bin/bash

join() {
    separator=$1
    shift 1
    list=("$@")
    result=${list[0]}
    for i in ${list[@]:1}; do
        result+=$separator
        result+=$i
    done
    echo $result
}

# test_statement '1 == 2'
# test_statement '-f ./go.sum'
test_statement() {
    statement=$1
    eval "test $statement" && echo_err "true" || echo_err "false"
    # OR
    # eval 'test $statement' && echo_err $? || echo_err $?
}

print_literal_string() {
    printf '%q\n' "$1"
}

# copy remote server file
# scp aws-desi-engineer-1:/tmp/uptime_kuma_data.tar.gz /tmp/uptime_kuma_data.tar.gz
copy_remote_file() {
    scp $1 $2
}
