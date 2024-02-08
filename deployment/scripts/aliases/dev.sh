#!/bin/bash

_dev_script_setup() {
    true
}

dev_add_command() (
	_dev_script_setup

	cobra-cli add $1 --config .cobra.yaml
)

dev_watch() (
	_dev_script_setup

	watchexec --no-project-ignore \
	-f '*.md' -f '*.yaml' -f '*.go' -f '*.templ' \
	-f 'tailwind.config.js' -f 'input.css' \
	--ignore '*_templ.go' --stop-signal 'SIGINT' \
	-r  -- dev_run
)

dev_html() (
	_dev_script_setup

	# This will restart the server only when .templ file changes and then refresh the browser via the proxy server
	templ generate --watch --proxy="http://0.0.0.0:3000" --cmd="dev_run_without_templ"
)

dev_run() (
	_dev_script_setup

	templ generate 
	dev_run_without_templ
)

dev_run_without_templ() (
	_dev_script_setup

	./bin/tailwindcss -i assets/css/dev/input.css -o assets/css/dev/output.css
	go run main.go serve
)
