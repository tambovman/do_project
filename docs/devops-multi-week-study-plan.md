# DevOps Lab - Multi-Week Study Plan

This document captures the long-term roadmap for the DevOps lab project.

## Lab Architecture

```text
Windows 11 Host
├── Jenkins controller
├── Linux agent01
├── app01
├── monitoring
├── Windows Jenkins agent
└── Kubernetes VM(s)
```

Planned network:

```text
Network: 192.168.57.0/24
Gateway: 192.168.57.2

jenkins     192.168.57.10
agent01     192.168.57.11
app01       192.168.57.20
monitoring  192.168.57.30
Windows     192.168.57.40
k8s         192.168.57.50
```

## Week 1 - Git, GitHub, and VS Code

Goals:

- repository setup
- branches
- commits
- pull requests
- merges
- `.gitignore`
- Markdown documentation

Expected flow:

```text
Local development
→ Git commit
→ GitHub branch
→ Pull request
→ Merge to main
```

## Week 2 - Jenkins Fundamentals

Goals:

- install Jenkins
- configure controller and Linux agent
- connect agent over SSH
- create Jenkins credentials
- use Pipeline as Code
- create Jenkinsfile
- connect GitHub webhook
- trigger builds automatically

Expected flow:

```text
VS Code
→ GitHub
→ webhook
→ Jenkins
→ agent01
→ Pipeline
```

## Week 3 - Docker CI/CD

Goals:

- create a small Flask app
- add `/health`
- containerize with Docker
- build Docker images in Jenkins
- run pytest
- run smoke tests
- tag images with build number and Git SHA
- push images to Docker Hub
- prepare `app01`

Expected flow:

```text
Git push
→ Jenkins
→ Docker build
→ Unit test
→ Smoke test
→ Docker Hub
```

## Week 4 - Automated Deployment and Rollback

Goals:

- deploy from Jenkins to `app01`
- use a dedicated `deploy` account
- use SSH credentials
- maintain `current-image` and `previous-image`
- verify deployment health
- roll back automatically after failed deployment
- test failures with environment variables

Expected flow:

```text
Git push
→ Jenkins
→ Build
→ Test
→ Push image
→ SSH to app01
→ Deploy
→ Health check
→ Rollback if failed
```

## Week 5 - Monitoring

Use:

```text
Prometheus
Grafana
Node Exporter
```

Monitor:

```text
jenkins
agent01
app01
monitoring
```

Practice:

- CPU
- memory
- disk
- network
- application health
- dashboards
- alerting

## Week 6 - Centralized Logging

Possible stack:

```text
Elasticsearch / OpenSearch
Logstash / Fluent Bit
Kibana / OpenSearch Dashboards
```

Collect:

- system logs
- Jenkins logs
- Docker logs
- application logs

Goal:

```text
Multiple servers
→ centralized log platform
→ search
→ dashboards
→ troubleshooting
```

## Week 7 - Ansible

Goals:

- inventory
- playbooks
- roles
- variables
- templates
- handlers
- idempotency

Automate:

```text
users
packages
Docker
SSH
directories
deployment files
monitoring agents
```

## Week 8 - Terraform

Goals:

- providers
- resources
- variables
- outputs
- state
- modules
- plan/apply/destroy

Practice workflow:

```text
Define infrastructure
→ terraform plan
→ review
→ terraform apply
→ verify
```

## Week 9 - Kubernetes

Topics:

```text
Pods
Deployments
Services
ConfigMaps
Secrets
Namespaces
liveness probes
readiness probes
rolling updates
rollback
```

Expected flow:

```text
Jenkins
→ Docker Hub
→ Kubernetes Deployment
→ Pods
→ Service
```

## Week 10 - Security and Operations

Topics:

- Jenkins RBAC
- least privilege
- SSH keys
- access tokens
- service accounts
- backups
- restore testing
- audit logs
- patching
- secrets management

Possible roles:

```text
Developer
DevOps Engineer
QA
Team Lead
Administrator
Deployment service account
```

## Windows Jenkins Agent

Keep the Windows VM for a later cross-platform CI phase.

Planned use:

```text
Windows Jenkins agent
PowerShell
Windows services
Windows-specific builds
cross-platform pipelines
```

## Ubuntu Desktop

Ubuntu Desktop is optional.

Useful later for:

```text
GUI testing
browser testing
Linux desktop practice
desktop application testing
```

Ubuntu Server remains preferred for:

```text
jenkins
agent01
app01
monitoring
```

## Final Integrated Architecture

```text
Developer
   ↓
GitHub
   ↓
Jenkins
   ↓
Linux / Windows agents
   ↓
Tests
   ↓
Docker registry
   ↓
Application server / Kubernetes
   ↓
Health verification
   ↓
Rollback
```

Monitoring:

```text
Application / Servers
   ↓
Prometheus
   ↓
Grafana
```

Logging:

```text
System / Application / Container logs
   ↓
Centralized logging
   ↓
Search and troubleshooting
```

Automation progression:

```text
Git
→ Jenkins
→ Docker
→ Ansible
→ Terraform
→ Kubernetes
```

## Final Project Outcome

By the end of the roadmap, the lab should demonstrate practical experience with:

```text
Git and GitHub
Jenkins
Pipeline as Code
Linux administration
Windows administration
SSH
Docker
Docker Hub
CI/CD
automated deployment
rollback
monitoring
Grafana
Prometheus
centralized logging
Ansible
Terraform
Kubernetes
security
backup and recovery
```

Each major phase should be developed on its own branch, merged through a pull request, verified on `main`, tagged, and documented under `docs/`.
