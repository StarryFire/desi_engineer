#!/bin/bash

git_force_push() {
    git add . && git commit --amend --no-edit && git push -f
}

# reset last unpushed commit without losing work
git_reset_soft_last_commit() {
    git reset --soft HEAD~1
}

# resets local commit history to that of the origin, losing all local changes
git_reset_hard_to_origin() {
    git reset --hard origin/main
}
