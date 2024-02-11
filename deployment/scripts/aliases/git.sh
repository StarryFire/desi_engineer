#!/bin/bash

git_force_push() {
    git add . && git commit --amend --no-edit && git push -f
}
