################################################### PUBLIC ###########################################################################

# Use '##' above the target to document it and show it in the listed targets of "help" screen 

# Changes the default shell in which makefile commands run
SHELL := /bin/bash
# .SHELLFLAGS := -e -c

# PHONY targets don't have any corresponding target/output file
.PHONY: help run install build

# All of the commands in the specified targets will run in a single shell environment
.ONESHELL: run install build

# Keep this at the top to make this the default command
default: help

## run any alias defined in the project in a subshell eg. make run cmd="command arg1 arg2 -f1 --f2 --f3=fv3"
run:
	@$(call parse_command_args)
	@source deployment/scripts/aliases/global.sh
	@load_all_aliases
	@_debug
	@$(command) $(command_args)

## install desi_engineer
install:
	@make run cmd="install"

## build desi_engineer
build:
	@make run cmd="build"

################################################### PRIVATE ###########################################################################

## lists all targets
help:
	@printf "Available targets:\n\n"
	@awk '/^[a-zA-Z\-_0-9%:\\]+/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
		helpCommand = $$1; \
		helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
	gsub("\\\\", "", helpCommand); \
	gsub(":+$$", "", helpCommand); \
		printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u
	@printf "\n"

# Make sure your targets/commands do not have the same name as any file/subdirectory in the directory containing this Makefile
# otherwise Makefile will think that the command is always up-to-date even when it is not: https://stackoverflow.com/a/3931814

# $(if $(filter $(arg_name), $(all_args_without_values)), echo "x", echo "y")
# # if [ $(arg_name) = $(filter $(arg_name), $(all_args_without_values)) ]; then \
# # 	echo "Condition met!"; \
# # fi
# $(foreach item,$(all_args_without_values), \
# $(if $(filter $(arg_name), $(all_args_without_values)), echo "woohoo", echo "boo") \
# ;)

# DO NOT PARSE FLAGS FROM "MAKEFLAGS" as that contains flags for the make command
# DO NOT PARSE ARGS FROM "MAKECMDGOALS" as these arguments are meant for the make command
define parse_command_args
	$(eval command := $(word 1, $(cmd)))
	$(eval command_args := $(filter-out $(command), $(cmd)))
endef

# -include tasks/*.mk

# IMAGES := cms tailscale nginx
# IMAGE_TARGETS := $(foreach path,$(IMAGES),docker/$(path))

# ## builds images
# $(IMAGE_TARGETS):
# 	@make run dc_build $(@:docker/%=%)