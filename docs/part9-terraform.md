# Part 9 — Terraform and AWS Infrastructure

## 1. Overview

This part of the DevOps project demonstrates Infrastructure as Code (IaC) using Terraform to provision AWS infrastructure for the `devops-demo` application.

The environment integrates Terraform, Amazon EC2, Amazon ECR, IAM, Docker, Jenkins, and Ansible.

**Objectives:**
- Provision reproducible AWS infrastructure using Terraform.
- Deploy a Dockerized application on EC2.
- Store application images in Amazon ECR.
- Use IAM roles instead of permanent credentials on EC2.
- Deploy application updates using Ansible.
- Verify application health and deployment idempotency.

## 2. AWS Infrastructure

**Region:** `us-east-1`

**Environment:** `lab`

**Resource prefix:** `devops-demo-lab`

| Resource | Configuration |
|---|---|
| VPC | `10.20.0.0/16` |
| Public subnet | `10.20.1.0/24` |
| Availability Zone | `us-east-1a` |
| Internet Gateway | Attached to VPC |
| Route table | Default route through Internet Gateway |
| EC2 | Ubuntu 24.04, `t3.micro` |
| EBS storage | 10 GB encrypted gp3 |
| Security group | SSH restricted to configured IP |
| IAM role | `devops-demo-lab-ec2-ecr` |
| ECR repository | `devops-demo` |

The EC2 instance hosts a Docker container running the application on `127.0.0.1:8080`.

The application is not directly exposed through a public HTTP port.

## 3. Terraform Configuration

Terraform code is stored in:

`terraform/aws/`

Important files:

- `providers.tf` — AWS provider configuration.
- `variables.tf` — configurable infrastructure parameters.
- `outputs.tf` — exported infrastructure information.
- `network.tf` — VPC, subnet, Internet Gateway, and routing.
- `security.tf` — security group and firewall rules.
- `ec2.tf` — EC2 instance configuration.
- `ecr.tf` — ECR repository and lifecycle policy.
- `iam.tf` — EC2 IAM role, permissions, and instance profile.

### Common Terraform commands

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

`terraform plan` compares the desired infrastructure configuration against the current AWS resources and Terraform state.

Final verification result:

```text
Success! The configuration is valid.

No changes. Your infrastructure matches the configuration.
```

## 4. Networking and Security

The VPC uses a public subnet with a route to the Internet Gateway.

The EC2 instance has a public IP address, but inbound SSH access is restricted to a configured source IP.

The application listens on the EC2 host's loopback address:

```text
127.0.0.1:8080
```

This prevents direct access to the application port from external networks.

The EC2 public IP is not static and may change after restarting the instance. The Ansible inventory must be updated when necessary.

## 5. IAM Authentication

The EC2 instance uses the IAM role:

`devops-demo-lab-ec2-ecr`

The role grants permissions required to authenticate to Amazon ECR and download images from the `devops-demo` repository.

EC2 obtains temporary credentials through its instance profile and AWS Instance Metadata Service (IMDSv2).

The EC2 server does not require permanent AWS access keys.

Authentication was verified with:

```bash
aws sts get-caller-identity --region us-east-1
```

The returned identity was an assumed IAM role associated with the EC2 instance.

## 6. Amazon ECR

Repository:

```text
992382477584.dkr.ecr.us-east-1.amazonaws.com/devops-demo
```

Configuration includes:
- Immutable image tags.
- Image scanning on push.
- Lifecycle policy retaining the latest 10 image artifacts.

The image `manual-test-001` was successfully published from Jenkins and downloaded to EC2.

Image digest:

```text
sha256:ccb9d72f15d882caa94fe6ba223d35c880b915fd035ebd3a7b7e34d446f77e89
```

## 7. Jenkins and Docker Image Publishing

Jenkins builds the application Docker image and authenticates to ECR using a dedicated IAM user's credentials stored in Jenkins Credentials.

The ECR publishing process:

1. Build the Docker image.
2. Validate application health in a temporary container.
3. Authenticate to Amazon ECR.
4. Tag the image using the ECR repository address.
5. Push the image to ECR.

The current publishing process was successfully tested manually through Jenkins. A fully automated, integrated CI/CD pipeline remains a future improvement.

## 8. Ansible Deployment

Deployment playbook:

`ansible/playbooks/aws-deploy.yml`

The playbook:
- Verifies that the requested Docker image is available locally.
- Inspects the running application container.
- Compares the desired and current image IDs and configuration.
- Replaces the application container when required.
- Checks application health.
- Attempts to restore the previous container if deployment fails.

The playbook uses:

```text
127.0.0.1:8080:8080
```

for Docker port binding and:

```text
unless-stopped
```

for the restart policy.

The image is currently specified in the playbook and can be overridden through Ansible variables.

### Deployment verification

The ECR image was successfully deployed to EC2.

The application's `/health` endpoint returned:

```json
{"status":"healthy"}
```

A second execution of the deployment playbook returned:

```text
changed=0
failed=0
```

This confirms idempotency for the tested deployment configuration.

### Rollback limitations

The deployment playbook includes a rollback mechanism that preserves the previous container temporarily.

Rollback logic is implemented, but its failure-recovery behavior has not yet been fully tested.

This approach also involves a short service interruption during container replacement. It is not a zero-downtime deployment strategy.

## 9. Verification Commands

### Terraform

```bash
terraform fmt -check
terraform validate
terraform plan
```

### EC2 identity

```bash
aws sts get-caller-identity --region us-east-1
```

### Docker

```bash
sudo docker ps
```

### Ansible syntax

```bash
ansible-playbook -i inventory/aws.ini \
  playbooks/aws-deploy.yml --syntax-check
```

### Ansible dry run

```bash
ansible-playbook -i inventory/aws.ini \
  playbooks/aws-deploy.yml --check --diff
```

### Application verification

```bash
ansible-playbook -i inventory/aws.ini \
  playbooks/aws-verify.yml
```

## 10. Operational Considerations

- EC2 and associated AWS resources may incur charges while provisioned.
- Stopping EC2 does not necessarily eliminate all related costs.
- The EC2 public IP may change after stopping and starting the instance.
- Terraform state and credentials must not be committed to GitHub.
- IAM permissions should be restricted to the resources and actions required.
- Docker images should use versioned, immutable tags.
- The ECR image must currently be pulled onto EC2 before the deployment playbook runs.

## 11. Future Improvements

- AWS EC2 dynamic inventory for Ansible.
- Fully automated Jenkins build, push, and deployment pipeline.
- Automatic ECR authentication and image pulling within deployment automation.
- Automated rollback failure-path testing.
- Remote Terraform state storage and locking.
- Improved secret management and credential rotation.
- Monitoring and alerting integration for AWS infrastructure.
- Kubernetes deployment using AWS EKS.

## 12. Conclusion

Part 9 established a functioning AWS infrastructure environment managed with Terraform.

The project successfully demonstrated:

**Terraform → AWS infrastructure → EC2 IAM authentication → ECR image distribution → Ansible deployment → application health verification.**

The infrastructure passed Terraform validation and drift checks, and the deployed application passed health and Ansible idempotency checks.
