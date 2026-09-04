# Part 2 - Jenkins CI Setup

This phase introduced Jenkins as the CI server for the DevOps lab and connected it to a dedicated Linux build agent and the GitHub repository.

## Infrastructure

Configured three Ubuntu Server VMs on the VMware NAT network:

- `jenkins` - `192.168.57.10`
- `agent01` - `192.168.57.11`
- `monitoring` - `192.168.57.30`

All three machines use static IPv4 addresses and can communicate with each other.

## Jenkins Controller

Installed on the `jenkins` VM:

- OpenJDK 21
- Git
- curl
- Jenkins LTS

Jenkins is managed as a `systemd` service and is available at:

`http://192.168.57.10:8080`

The Jenkins controller was configured so normal builds run on agents instead of the Built-In Node.

## Jenkins Agent

Prepared `agent01` with:

- OpenJDK 21
- Git
- dedicated Linux user: `jenkins`
- SSH access from the Jenkins controller

A dedicated SSH key pair was created on the Jenkins controller.

The public key was added to:

`/home/jenkins/.ssh/authorized_keys`

on `agent01`.

The private key was stored in Jenkins Credentials.

The agent is connected using:

- Host: `192.168.57.11`
- User: `jenkins`
- Launch method: SSH
- Label: `linux`

Jenkins successfully launches the agent using Jenkins Remoting.

## Storage Fixes

The Ubuntu installer created a 20 GB virtual disk but only allocated approximately 10 GB to the root LVM logical volume.

The logical volume was expanded to use all available free space:

```bash
sudo lvextend -l +100%FREE -r /dev/ubuntu-vg/ubuntu-lv

working CI chain is now:
VS Code
   ↓ git push
GitHub
   ↓ webhook
Smee.io
   ↓
Jenkins controller
192.168.57.10
   ↓ SSH / Remoting
agent01
192.168.57.11
   ↓
Pipeline
   ↓
SUCCESS