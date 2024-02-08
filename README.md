## Desi Blog

This is the source code for my blog: [blog.desiengineer.dev](https://blog.desiengineer.dev)

#### Dependencies

- golang 1.21.5
- [watchexec](https://github.com/watchexec/watchexec)

#### How To Setup

- Install watchexec: https://github.com/watchexec/watchexec#install

##### Mac (ARM)

- Run: `make mac_arm_install`

##### Others

- Install tailwind cli: https://tailwindcss.com/blog/standalone-cli to `bin/tailwindcss`
- Install minify cli: https://github.com/tdewolff/minify/releases to `bin/minify`

#### How to generate new commands

`cobra-cli add serve --config ./.cobra.yaml`

#### How To Run

`make dev`
