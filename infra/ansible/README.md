# Ansible Playbooks

This directory contains Ansible playbooks for server configuration.

## Status

Ansible automation is planned for future development.

## Structure

```text
ansible/
├── inventory/          # Host inventories
├── playbooks/          # Playbook files
├── roles/              # Reusable roles
└── ansible.cfg         # Ansible configuration
```

## Usage

Run playbooks:

```bash
ansible-playbook --inventory inventory/hosts playbooks/setup.yml
```
