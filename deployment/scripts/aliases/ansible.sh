#!/bin/bash

ansible_install() {
    ansible-playbook $ANSIBLE_PLAYBOOKS_DIR/install.yaml
}

ansible_configure() {
    ansible-playbook $ANSIBLE_PLAYBOOKS_DIR/configure.yaml
}

ansible_deploy() {
    ansible-playbook $ANSIBLE_PLAYBOOKS_DIR/deploy.yaml
}

ansible_force_deploy() {
    ansible-playbook $ANSIBLE_PLAYBOOKS_DIR/deploy.yaml -e "flags='-f'"
}

ansible_push() {
    ansible-playbook $ANSIBLE_PLAYBOOKS_DIR/push.yaml
}
