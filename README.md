## Desi Blog

This is the source code for my blog: [blog.desiengineer.dev](https://blog.desiengineer.dev)

#### Dependencies

- golang 1.21.5
- [watchexec](https://github.com/watchexec/watchexec)

#### How To Setup

- Install watchexec: https://github.com/watchexec/watchexec#install
- Run: `make install`

#### How to generate new commands

`cobra-cli add serve --config ./.cobra.yaml`

#### How To Run

`make run cmd="start_dev"`
