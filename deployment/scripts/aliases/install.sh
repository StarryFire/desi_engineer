#!/bin/bash

#################################################### PUBLIC ################################################################################
install() {
	_install_go_deps
	_install_minify
	_install_cwebp
	_install_tailwindcss
}

#################################################### PRIVATE ################################################################################

_install_go_deps() {
	go mod download
	go install github.com/a-h/templ/cmd/templ@v0.2.501
}


_install_minify() {
	mkdir -p bin/tmp/minify

	case $ARCH in
	$ARCH_ARM64)
		curl -o bin/tmp/minify/minify.tar.gz -sLO https://github.com/tdewolff/minify/releases/download/v2.20.14/minify_darwin_arm64.tar.gz
		;;
	$ARCH_AARCH64)
		curl -o bin/tmp/minify/minify.tar.gz -sLO https://github.com/tdewolff/minify/releases/download/v2.20.15/minify_linux_arm64.tar.gz
		;;
	$ARCH_x86_64)
		curl -o bin/tmp/minify/minify.tar.gz -sLO https://github.com/tdewolff/minify/releases/download/v2.20.14/minify_linux_amd64.tar.gz
		;;
	*)
		exit 1
		;;
	esac

	tar -xzf bin/tmp/minify/minify.tar.gz -C bin/tmp/minify
	mv bin/tmp/minify/minify bin/minify

	if [ $ARCH = $ARCH_ARM64 ]; then
		xattr -dr com.apple.quarantine bin/minify
	fi

	rm -rf bin/tmp
}

_install_cwebp() {
	mkdir -p bin/tmp/cwebp

	case $ARCH in
	$ARCH_ARM64)
		curl -o bin/tmp/cwebp/cwebp.tar.gz -sLO https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.3.2-mac-arm64.tar.gz
		tar -xzf bin/tmp/cwebp/cwebp.tar.gz -C bin/tmp/cwebp
		mv bin/tmp/cwebp/libwebp-1.3.2-mac-arm64/* bin/tmp/cwebp/
		;;
	$ARCH_AARCH64)
		curl -o bin/tmp/cwebp/cwebp.tar.gz -sLO https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.3.2-linux-aarch64.tar.gz
		tar -xzf bin/tmp/cwebp/cwebp.tar.gz -C bin/tmp/cwebp
		mv bin/tmp/cwebp/libwebp-1.3.2-linux-aarch64/* bin/tmp/cwebp/
		;;
	$ARCH_x86_64)
		curl -o bin/tmp/cwebp/cwebp.tar.gz -sLO https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.3.2-linux-x86-64.tar.gz
		tar -xzf bin/tmp/cwebp/cwebp.tar.gz -C bin/tmp/cwebp
		mv bin/tmp/cwebp/libwebp-1.3.2-linux-x86-64/* bin/tmp/cwebp/
		;;
	*)
		exit 1
		;;
	esac

	# Make sure to use cwebp for only images with high resolution as images with low resolution don't compress well into webp format
	tar -xzf bin/tmp/cwebp/cwebp.tar.gz -C bin/tmp/cwebp
	mv bin/tmp/cwebp/bin/cwebp bin/cwebp

	if [ $ARCH = $ARCH_ARM64 ]; then
		xattr -dr com.apple.quarantine bin/cwebp
	fi

	rm -rf bin/tmp
}

_install_tailwindcss() {
	mkdir -p bin

	case $ARCH in
	$ARCH_ARM64)
		curl -o bin/tailwindcss -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.1/tailwindcss-macos-arm64
		;;
	$ARCH_AARCH64)
		curl -o bin/tailwindcss -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.1/tailwindcss-linux-arm64
		;;
	$ARCH_x86_64)
		curl -o bin/tailwindcss -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.1/tailwindcss-linux-x64
		;;
	*)
		exit 1
		;;
	esac
	chmod +x bin/tailwindcss
}