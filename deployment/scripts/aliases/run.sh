#!/bin/bash

# run all your aliases in an isolated subshell
run() {
    bash -c '
    source deployment/scripts/aliases/global.sh
    load_all_aliases
    _debug
    echo_err "[run] running: $@"
    $@
    ' _ $@
}

_get_all_local_function_names_list() {
    env -i bash --noprofile --norc -c "
    source deployment/scripts/aliases/global.sh
    load_all_aliases
    declare -F | cut -d ' ' -f3 | tr '\n' ' '
    "
}

_enable_run_autocompletion() {
    fn_names_list=$(_get_all_local_function_names_list)
    complete -W "$fn_names_list" run
}
