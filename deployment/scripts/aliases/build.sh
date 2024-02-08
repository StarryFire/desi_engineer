#!/bin/bash

clean() (
	rm -rf tmp/*
	rm bin/desi_engineer
)


build() {
	# CGO_ENABLED=0
	# This flag disables cgo, which is a feature in Go that allows the creation 
	# of Go packages that call C code. Disabling cgo can make the resulting binary statically linked, which 
	# is beneficial when creating Docker images because it reduces the image size and eliminates 
	# the need for a C compiler at runtime. However, it also means that your Go program can't use 
	# any C libraries, which might limit its functionality

	# GOOS=linux
	# This flag sets the operating system target for the binary.

	# -s -w
	# Removes symbol and debug info
	# When you compile a Go program, it keeps a separate part of the binary that would 
	# be used for debugging; however, this extra information uses memory and is not necessary 
	# to preserve when deploying to a production environment.

	# @./bin/tailwindcss -i assets/css/dev/input.css -o assets/css/prod/output.css --minify
	templ generate
	./bin/minify -r -o ./assets/js/prod/ ./assets/js/dev/
	./bin/minify -r -o ./assets/css/prod/ ./assets/css/dev/

	case $ARCH in
	$ARCH_ARM64)
		CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w" -o bin/desi_engineer
		;;
	$ARCH_AARCH64)
		CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o bin/desi_engineer main.go
		;;
	$ARCH_x86_64)
		CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/desi_engineer main.go
		;;
	*)
		echo "platform not supported"
		exit 1
		;;
	esac
}