
# Goal: Use Ansible to configure the local Ubuntu system on WSL2 for practice.
# The task was to create a localhost Ansible lab, install and manage Nginx,
# understand playbooks, roles, inventory, become, and troubleshoot real errors.
# Prove that Ansible can manage the local machine and explain the problems faced during execution.

# What this task is and why
This task was created to practice Ansible on the local machine instead of a remote server.
The purpose was to understand how Ansible works with localhost using ansible_connection=local,
how a playbook calls roles and tasks, and how Ansible manages packages and services on Ubuntu.
It also helped in learning troubleshooting when automation fails because of system issues.

# What you implemented
Created an Ansible lab in WSL2 with:

- An inventory targeting the local machine.
- An ansible.cfg file for project configuration.
- A ping-local playbook to test localhost execution.
- A setup-nginx playbook to configure the system.
- A custom nginx role inside roles/nginx/tasks/main.yml.

# Folder structure used

ansible-lab/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── playbooks/
│   ├── ping-local.yml
│   └── setup-nginx.yml
└── roles/
    └── nginx/
        └── tasks/
            └── main.yml

# Inventory
The inventory was configured for localhost so that Ansible runs directly on the same machine.

Example:
[local]
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3

# Playbook and role
The setup-nginx playbook was used to apply the nginx role on localhost.

The role performed:
- APT cache update
- Nginx package installation
- Nginx service enable and start

# What the task was supposed to prove
- Ansible can run on localhost without any remote server.
- Ansible playbooks can automate package installation and service management.
- Roles help organize reusable tasks.
- become: true is required for root-level tasks.
- The playbook should be idempotent, meaning re-running should not make unnecessary changes.

# Commands used

ansible localhost -m ping

ansible-playbook playbooks/ping-local.yml

ansible-playbook playbooks/setup-nginx.yml --ask-become-pass

sudo apt update

sudo systemctl status nginx

# Challenges faced during this task

1. YAML callback plugin error
Error:
The 'community.general.yaml' callback plugin has been removed.

Reason:
The old YAML callback plugin is removed in new Ansible versions.
The correct method is to use the default callback with YAML result formatting.

Fix:
Updated ansible.cfg to use:
stdout_callback = default
callback_result_format = yaml

2. Role not found error
Error:
the role 'nginx' was not found

Reason:
Ansible could not find the custom role because the role path or folder structure was incorrect.

Fix:
Created the role in the correct path:
roles/nginx/tasks/main.yml
Also configured roles_path properly in ansible.cfg.

3. Sudo password required
Error:
sudo: a password is required

Reason:
The playbook used become: true, but Ansible was not given the sudo password.

Fix:
Ran the playbook with:
ansible-playbook playbooks/setup-nginx.yml --ask-become-pass

4. APT cache update failed
Error:
Failed to update apt cache after 5 retries

Reason:
The local apt repository files were broken.
Third-party repositories had malformed entries because URLs were written in invalid format.

Fix:
Corrected the repository files in /etc/apt/sources.list.d/
Then verified using:
sudo apt update

5. Nginx service failed to start
Error:
Job for nginx.service failed because the control process exited with error code.

Reason:
Apache was already using ports 80 and 443, so Nginx could not bind to those ports.

Fix:
Identified the conflict using service status and port checks.
Decided not to stop Apache and planned to configure Nginx on another port instead.

# What you learned from the challenges
These problems helped in understanding that Ansible automation also depends on the system state.
If apt is broken, Ansible apt module will fail.
If sudo is not handled correctly, become tasks will fail.
If a service port is already occupied, service startup will fail.
So Ansible not only teaches automation but also Linux troubleshooting.

# Output / result
- Localhost inventory was configured successfully.
- Ping playbook worked successfully.
- Role-based playbook structure was created successfully.
- Multiple real-world errors were identified and understood.
- The system issues behind Ansible failures were analyzed and fixed step by step.

# Purpose of this task
The main purpose of this task was to build a beginner-friendly Ansible lab and understand:
- Inventory
- Playbooks
- Roles
- Modules
- Local execution
- Privilege escalation
- Package management
- Service management
- Troubleshooting in Ansible

# Conclusion
This task was useful for learning practical Ansible.
It showed how Ansible works on localhost, how roles are used, and how real errors appear during automation.
It also improved understanding of Linux package repositories, sudo behavior, and service port conflicts.




-- To access a playbook we use this command:-

```
   ansible-playbook -i ../hosts.ini file name.yml -v

```

# playbook hello.yml file

```

   ---
- name: Configure localhost with nginx
  hosts: localhost
  connection: local
  gather_facts: true
  become: true

  vars:
    nginx_port: 8081

  tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true

    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
        state: present

    - name: Configure nginx to listen on custom port
      ansible.builtin.replace:
        path: /etc/nginx/sites-available/default
        regexp: 'listen 80 default_server;'
        replace: 'listen {{ nginx_port }} default_server;'

    - name: Configure nginx IPv6 listen on custom port
      ansible.builtin.replace:
        path: /etc/nginx/sites-available/default
        regexp: 'listen \[::\]:80 default_server;'
        replace: 'listen [::]:{{ nginx_port }} default_server;'

    - name: Test nginx configuration
      ansible.builtin.command: nginx -t
      register: nginx_test
      changed_when: false

    - name: Ensure nginx service is enabled and started
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true

    - name: Show nginx test result
      ansible.builtin.debug:
        var: nginx_test.stderr_lines

```

#  hosts.ini

```
   [servers]
server1 ansible_host=13.233.10.10
server2 ansible_host=13.233.10.11

[servers:vars]
ansible_user=ubuntu
ansible_port=22
ansible_ssh_private_key_file=~/.ssh/my-ec2-key.pem

```
# Test the inventory

ansible servers -i inventory/hosts.ini -m ping


# Playbook to insatll multiple packages

```
  - name: Install Packages
  hosts: servers
  become: yes

  vars:
    packages_to_install:
      - tree
      - zip
      - unzip
      - jq
      - wget
      - apache2

  tasks:
    - name: Install Package
      apt:
        name: "{{ item }}"
        state: present
      loop: "{{ packages_to_install }}"
   - name: Show message
       loop: "{{ packages_to_install }}"
       debug:
         msg: "installing {{ item }}"

```

# When condition 

# To encrypt data

ansible-vault encrypt secrets.yml --vault-password-file vault_password.txt

```
