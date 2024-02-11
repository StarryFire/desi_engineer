#!/bin/bash

############################################# GLOBALS ########################################################################################

ARCH="$(uname -m)"
ARCH_ARM64="arm64"
ARCH_x86_64="x86_64"
ARCH_AARCH64="aarch64"

# The location of the base file decides the relative paths in all docker-compose files
DOCKER_COMPOSE_BASE_FILE=deployment/services/base_docker_compose.yaml

DOCKER_COMPOSE_MONITORING_COLLECTORS_FILE=deployment/services/monitoring_collectors_docker_compose.yaml
DOCKER_COMPOSE_MONITORING_EXPORTERS_FILE=deployment/services/monitoring_exporters_docker_compose.yaml
DOCKER_COMPOSE_PROXY_FILE=deployment/services/proxy_docker_compose.yaml
DOCKER_COMPOSE_PRIVATE_PROXY_FILE=deployment/services/private_proxy_docker_compose.yaml
DOCKER_COMPOSE_VOLUMES_FILE=deployment/services/volumes_docker_compose.yaml
DOCKER_COMPOSE_NETWORKS_FILE=deployment/services/networks_docker_compose.yaml
DOCKER_COMPOSE_FILES="-f $DOCKER_COMPOSE_BASE_FILE -f $DOCKER_COMPOSE_VOLUMES_FILE -f $DOCKER_COMPOSE_NETWORKS_FILE -f $DOCKER_COMPOSE_PROXY_FILE -f $DOCKER_COMPOSE_PRIVATE_PROXY_FILE -f $DOCKER_COMPOSE_MONITORING_EXPORTERS_FILE -f $DOCKER_COMPOSE_MONITORING_COLLECTORS_FILE"

# Required to be exported otherwise ansible doesn't pick this up
export ANSIBLE_CONFIG=deployment/ansible/ansible.cfg
ANSIBLE_PLAYBOOKS_DIR="deployment/ansible/playbooks"

############################################# PUBLIC ########################################################################################

echo_err() {
    echo "$@" 1>&2
}

load_all_aliases() {
    if [ -d deployment/scripts/aliases ]; then
        for file in deployment/scripts/aliases/*; do
            if [ -f $file ] && [ "$file" != 'deployment/scripts/aliases/global.sh' ]; then
                source $file
            fi
        done
    fi
}

############################################# PRIVATE ########################################################################################

_copy_nginx_files() {
    # Keeps the tmp folders entirely in sync with the main folders while keeping .gitkeep and default files in the target folder
    # need to keep these files in sync in order to correctly deploy nginx
    rsync -a --delete --exclude=".gitkeep" --exclude="default" deployment/services/proxy/nginx/vhost.d/ deployment/services/proxy/nginx/data/etc_nginx_vhost.d
    rsync -a --delete --exclude=".gitkeep" --exclude="default.conf" deployment/services/proxy/nginx/conf.d/ deployment/services/proxy/nginx/data/etc_nginx_conf.d
}

_print_stack() {
    local err=$1
    local stack_size=${#FUNCNAME[@]}

    if [ $stack_size -gt 2 ]; then
        # to avoid noise we start with 2 to remove the _print_stack & handle_error functions from the final error trace
        local -i i
        i=2
        local function_name_where_error_occured=${FUNCNAME[$i]}
        local -i line_no_where_error_occured=${BASH_LINENO[$((i - 1))]}
        local file_name_where_error_occured="${BASH_SOURCE[$i]}"
        local -a stack=("Stack Trace: parent_shell_pid: ($$) subshell_pid: ($BASHPID)")
        stack+=("    ($((i - 2))) $function_name_where_error_occured $file_name_where_error_occured:$line_no_where_error_occured")
        i+=1
        for ((i = 3; i < stack_size; i++)); do
            local func="${FUNCNAME[$i]}"
            local -i line="${BASH_LINENO[$((i - 1))]}"
            local src="${BASH_SOURCE[$i]}"
            stack+=("    ($((i - 2))) $func")
        done
        (
            IFS=$'\n'
            echo_err "${stack[*]}"
        )
    fi

    exit $err
}

# run this in the shell where you want scripts to exit as soon as they encounter an error and then print a stacktrace
function _debug() {
    set -o pipefail
    set -u
    set -e # exits on error

    set -E

    trap 'handle_error' ERR
    trap 'handle_interrupt' INT
    # trap 'handle_exit' EXIT

    error_occurred=0
    handle_error() {
        exit_code=$?
        _print_stack $exit_code

        echo_err "Exiting with err: $exit_code"
        error_occurred=1
        exit $exit_code
    }

    interrupt_occured=0
    handle_interrupt() {
        exit_code=$?
        echo_err "[INTERRUPT: script cancelled by user]"
        interrupt_occured=1
        exit $exit_code
    }

    handle_exit() {
        exit_code=$?
        if [ "$error_occurred" -eq 0 ] && [ "$interrupt_occured" -eq 0 ]; then
            # echo_err "$error_occurred $interrupt_occured";
            if [ "$exit_code" -ne 0 ]; then
                echo_err "[EXIT: script failed with exit code $exit_code]"
            else
                echo_err "[EXIT: script ran successfully.]"
            fi
            exit $exit_code
        fi
    }
}

############################################# KNOWLEDGE ########################################################################################
# PRO_TIP: declare functions as codeblocks func() {...} rather than subshells func() (...)
# Why? Because each subshell runs in a different process and hence can be expensive to run
# In order to not pollute the global shell environment, simply call your functions within a subshell like: (func)

# Same this as above but with different format
# function _print_stack() {
#     local err=$1

#     set +o xtrace
#     echo_err "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}." >&2
#     echo_err "'${BASH_COMMAND}' exited with status $err"     >&2
#     # to avoid noise we start with 2 to skip the stack & error trap functions
#     for ((i=2;i<${#FUNCNAME[@]};i++)); do
#         local script=${BASH_SOURCE[$i]}
#         local lineno=${BASH_LINENO[$i-1]}
#         local funcname=${FUNCNAME[$i]}
#         if [[ "${script:0:1}" != / && "${script:0:2}" != ~[/a-z] ]]; then
#             script="${SCRIPT_DIR}/$script"
#         fi
#         echo_err "$script:$lineno $funcname"  >&2
#         awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$script }' L=$lineno $script  >&2
#     done
# }

# function _print_stack() {
#     local err=$1

#     local -a stack=("Stack Trace: parent_shell_pid: $$ subshell_pid: $BASHPID function: ${FUNCNAME[2]}")
#     local stack_size=${#FUNCNAME[@]}
#     local -i i
#     # to avoid noise we start with 2 to skip the stack & error trap functions
#     for (( i = 2; i < stack_size; i++ )); do
#     local func="${FUNCNAME[$i]:-(top level)}"
#     local -i line="${BASH_LINENO[$(( i - 1 ))]}"
#     local src="${BASH_SOURCE[$i]:-(no file)}"
#     stack+=("    ($i) $func $src:$line")
#     done
#     (IFS=$'\n'; echo_err "${stack[*]}")

#     exit $err
# }

# Same this as above but with different format
# function _print_stack() {
#     local err=$1

#     STACK=""
#     local i message="${1:-""}"
#     local stack_size=${#FUNCNAME[@]}
#     # to avoid noise we start with 1 to skip the get_stack function
#     for (( i=1; i<stack_size; i++ )); do
#         local func="${FUNCNAME[$i]}"
#         [[ $func = "" ]] && func=MAIN
#         local linen="${BASH_LINENO[$(( i - 1 ))]}"
#         local src="${BASH_SOURCE[$i]}"
#         [[ "$src" = "" ]] && src=non_file_source

#         STACK+=$'\n'"   at: $func $src "$linen
#     done
#     STACK="${message}${STACK}"
#     echo -e "$STACK"

#     exit $err
# }

# Somethings to note about traps:
# - By default, each trap is tightly tied to the subshell/shell they are defined in i.e. by default, no trap is inherited by inner subshells.
# If you want inheritance, you will have to define the traps in each subshell via bash code expansion/block
# - EXIT trap is triggered at the very end after all the other traps are processed. The execution of traps looks like this: INT/ERR -> EXIT
# - exit_code and signals are processed differently and are not the same. INT will only be triggered for the subshell
# where the interrupt happened, and only the final exit_code of the inner shell will be passed to the outer shells (not the signal), so the outer shells INT trap will not be triggered
# - set -E: only causes set -e to be inherited by code block

# error traps defined in the same shell as the one that exited with non-zero code, won't get triggered
# i.e. handle_error will only be called if a subshell of the calling shell exited with non-zero code
# for eg.
# in the following handle_error will not be called since the exit code was triggered by the calling shell itself
# outer() (
#     trap 'handle_error "ERROR"' ERR
#     exit 1
# )
# however, here, since "exit 1" is within a subshell, handle_error will get triggered
# outer() (
#     trap 'handle_error "ERROR"' ERR
#     (exit 1)
#     # false # same as writing (exit 1)
# )

# reverse_list() {
#     list=($@)
#     unset list[0] # removes the trap function itself from the call stack
#     reversed_list=$(printf '%s\n' "${list[@]}" | tac | tr '\n' ' ')
#     echo_err "${reversed_list::-1}"
# }

# handle_err_inner_subshell() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] ERR INNER_SUBSHELL!!!!! $exit_code"
#     exit $exit_code
# }
# handle_int_inner_subshell() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] INT INNER_SUBSHELL!!!!! $exit_code"
#     exit $exit_code
# }
# handle_exit_inner_subshell() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] EXIT INNER_SUBSHELL!!!!! $exit_code"
#     exit $exit_code
# }
# inner_subshell() (
#     # Since these traps are defined inside a new shell/subshell, so by default, these will only be linked to this shell i.e. inner_subshell
#     trap 'handle_err_inner_subshell $FUNCNAME' ERR
#     trap 'handle_int_inner_subshell $FUNCNAME' INT
#     trap 'handle_exit_inner_subshell $FUNCNAME' EXIT

#     echo_err "inner_subshell enter"
#     sleep 1s;
#     $1
#     echo_err "inner_subshell exit"
# )

# handle_err_inner_block() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] ERR INNER_BLOCK!!!!! $exit_code"
#     exit $exit_code
# }
# handle_int_inner_block() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] INT INNER_BLOCK!!!!! $exit_code"
#     exit $exit_code
# }
# handle_exit_inner_block() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] EXIT INNER_BLOCK!!!!! $exit_code"
#     exit $exit_code
# }
# # block/expansion
# inner_block() {
#     # # Since these traps are defined inside a code expansion/block, these will overwrite any traps that were defined in the shell that runs this code expansion i.e. outer_shell
#     # trap 'handle_err_inner_block $FUNCNAME' ERR
#     trap 'handle_int_inner_block $FUNCNAME' INT
#     trap 'handle_exit_inner_block $FUNCNAME' EXIT

#     echo_err "inner_block enter"
#     sleep 1s;
#     $1
#     echo_err "inner_block exit"
# }

# if_else_block() {
#     echo_err "if_else_block enter"
#     sleep 1s
#     if [ $1 -eq 1 ]; then
#         echo_err "running if block";
#         false;
#     elif [ $1 -eq 0 ]; then
#         echo_err "running elif block";
#         true;
#     fi
#     echo_err "if_else_block exit"
# }

# x_block() {
#     echo_err "hello"
#     inner_block false
# }

# handle_err_outer_subshell() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     # echo_err "${FUNCNAME[@]}"
#     echo_err "[${reversed_call_stack[@]}] ERR OUTER_SUBSHELL!!!!! $exit_code"
#     _print_stack $exit_code
#     exit $exit_code
# }
# handle_int_outer_subshell() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] INT OUTER_SUBSHELL!!!!! $exit_code"
#     exit $exit_code
# }
# handle_exit_outer_subshell() {
#     exit_code=$?
#     func_name=$1
#     reversed_call_stack=$(reverse_list ${FUNCNAME[@]})
#     echo_err "[${reversed_call_stack[@]}] EXIT OUTER_SUBSHELL!!!!! $exit_code"
#     exit $exit_code
# }

# # Example code to try out traps!
# outer_subshell() {
#     # this causes the script to exit as soon as a command triggers an error
#     # set -e

#     # this causes the ERR trap to be inherited by the inner subshells and code blocks of this shell
#     # NOTE: Only 1 trap per kind(EXIT/ERR/INT/etc) can be triggered per shell
#     # Therefore if a trap gets inherited by a code block, then when the shell's trap gets triggered by a command in that code block, only that code block's trap will
#     # be triggered for the entire shell process.
#     set -E

#     # By default, these traps won't be inherited by the inner subshells of this shell
#     # the commands defined here is triggered directly inside the shell and function that triggers them
#     trap 'handle_err_outer_subshell $FUNCNAME' ERR
#     trap 'handle_int_outer_subshell $FUNCNAME' INT
#     trap 'handle_exit_outer_subshell $FUNCNAME' EXIT

#     echo_err "outer_subshell enter"

#     # These are different ways to invoke subshells in bash.
#     #
#     # (false)
#     # functions basically substitute their value (...) or {...} in the bash script from where they are called.
#     # inner_subshell false
#     # # So basically the above is the same as below, with one slight difference, the above
#     # # adds the function to the callstack of the calling shell whereas the below doesn't since there is no function call involved
#     # (
#     #     # Since these traps are defined inside a new shell/subshell, so by default, these will only be linked to this shell i.e. inner_subshell
#     #     trap 'handle_err_inner_subshell $FUNCNAME' ERR
#     #     trap 'handle_int_inner_subshell $FUNCNAME' INT
#     #     trap 'handle_exit_inner_subshell $FUNCNAME' EXIT

#     #     echo_err "inner_subshell enter"
#     #     sleep 1s;
#     #     false
#     #     echo_err "inner_subshell exit"
#     # )
#     # In this case, the function call is part of the subshell that is created and hence it is added to the callstack of the newly created subshell
#     # (inner_block false)

#     # inner_block false
#     if_else_block 0
#     sleep 1s;
#     # false
#     echo_err "outer_subshell exit"
# }

# Note: if no exit statement is specified in a function, it will exit with the exit code of the last statement in the function
# Note: if no exit statement is specified in a subshell, it will exit with the exit code of the last statement in the subshell
# install_test() {
# 	# false
# 	exit 1
# 	echo_err "hello"
# }

# install_test2() {
# 	set -eEuo pipefail

# 	# since set -e is not inherited by subshells, this will not stop the execution of this function inside the subshell when false is encountered inside install_test
# 	# however, if you exit the subshell itself with "exit 1", not only will it stop execution inside install_test1
# 	# it will also be treated as if a statement inside install_test2 exited with code 1
# 	# and hence will stop the execution inside install_test2 here
# 	# $(install_test)
# 	# echo "output: $output, exit: $?"

# 	# however if the subshell exited with non-zero code inside condition of a if/else, then the execution will not stop
# 	if $(install_test); then
# 		echo "y";
# 	else
# 		echo "n";
# 	fi
#
