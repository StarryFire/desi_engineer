#!/bin/bash

join() {
    separator=$1
    shift 1
    list=("$@")
    result=${list[0]}
    for i in ${list[@]:1}; do
        result+=$separator;
        result+=$i;
    done
    echo $result
}

# test_statement '1 == 2'
test_statement() {
    statement=$1
    eval "test $statement" && echo_err "true" || echo_err "false"
    # OR
    # eval 'test $statement' && echo_err $? || echo_err $?
}

print_literal_string() {
    printf '%q\n' "$1"
}