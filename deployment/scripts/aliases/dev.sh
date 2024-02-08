#!/bin/bash

################################################## PUBLIC ##################################################

dev_add_command() (
	_dev_script_setup

	cobra-cli add $1 --config .cobra.yaml
)

start_dev_watch() (
	_dev_script_setup

	watchexec --no-project-ignore \
		-f '*.md' -f '*.yaml' -f '*.go' -f '*.templ' \
		-f 'tailwind.config.js' -f 'input.css' \
		--ignore '*_templ.go' --stop-signal 'SIGINT' \
		-r -- make run cmd="start_dev"
)

start_dev_html() (
	_dev_script_setup

	# This will restart the server only when .templ file changes and then refresh the browser via the proxy server
	templ generate --watch --proxy="http://0.0.0.0:3000" --cmd="dev_run_without_templ"
)

start_dev() (
	_dev_script_setup

	templ generate
	_start_dev_templ
)

################################################## Private ##################################################

_start_dev_templ() (
	_dev_script_setup

	./bin/tailwindcss -i assets/css/dev/input.css -o assets/css/dev/output.css
	go run main.go serve
)

_dev_script_setup() {
	true
}
