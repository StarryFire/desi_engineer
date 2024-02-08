#!/bin/bash

_go_script_setup() {
    true
}

go_test() (
    _go_script_setup

    go test -v ./...
)

go_test_coverage() (
    _go_script_setup

    go test ./... -coverprofile=tmp/coverage.out
)
