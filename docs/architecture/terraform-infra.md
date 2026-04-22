# Terraform Infrastructure Deep Dive

This document explains exactly what Terraform creates and why each piece exists.

## What Terraform Creates

Terraform entrypoint:

- infra/terraform/environments/dev/main.tf

Modules used:

- network module
- security module
- compute module

## 1. Network Layer

Files:

- infra/terraform/modules/network/main.tf
- infra/terraform/modules/network/variables.tf
- infra/terraform/modules/network/outputs.tf

Resources:

1. aws_vpc.main
- Creates a dedicated VPC.
- CIDR comes from `vpc_cidr` (default 10.0.0.0/16).
- DNS support and DNS hostnames are enabled.

2. aws_subnet.public
- Creates one public subnet in the VPC.
- CIDR comes from `public_subnet_cidr` (default 10.0.1.0/24).
- `map_public_ip_on_launch = true` so EC2 gets a public IP.
- AZ is either:
  - `availability_zone` if you set it, or
  - first available AZ automatically.

3. aws_internet_gateway.igw
- Connects your VPC to the internet.

4. aws_route_table.public
- Adds route `0.0.0.0/0 -> Internet Gateway`.
- This is what gives outbound internet and public reachability.

5. aws_route_table_association.public
- Attaches the route table to the public subnet.

## 2. Security Layer

Files:

- infra/terraform/modules/security/main.tf
- infra/terraform/modules/security/variables.tf
- infra/terraform/modules/security/outputs.tf

Resource:

1. aws_security_group.app

Ingress rules:

- SSH 22 from `allowed_ssh_cidrs`
- HTTP 80 from `allowed_public_http_cidrs`
- HTTPS 443 from `allowed_public_http_cidrs`
- Kubernetes API 6443 from `allowed_k8s_api_cidrs`
- NodePort 30000-32767 from `allowed_nodeport_cidrs`

Egress rule:

- All outbound traffic allowed (0.0.0.0/0)

Why these ports:

- 22: SSH administration and Ansible access.
- 80/443: app access through reverse proxy or ingress later.
- 6443: k3s API server remote access.
- 30000-32767: NodePort services for quick external exposure in project setup.

## 3. Compute Layer

Files:

- infra/terraform/modules/compute/main.tf
- infra/terraform/modules/compute/variables.tf
- infra/terraform/modules/compute/outputs.tf

Resources/Data:

1. aws_key_pair.deployer
- Uploads your public SSH key to AWS.
- EC2 instance uses this key pair for SSH login.

2. data.aws_ami.ubuntu
- Dynamically selects latest Ubuntu 22.04 LTS image from Canonical.
- Avoids hardcoded AMI IDs.

3. aws_instance.app_server
- Creates EC2 instance in the public subnet.
- Uses selected instance type (m7i-flex.large default).
- Attaches security group from security module.
- Associates public IP.
- Configures gp3 root volume with configurable size.
- Enforces IMDSv2 (`http_tokens = required`) for better metadata security.
- Applies tags for Project and ManagedBy metadata.

Safety guard:

- If `free_tier_only = true`, Terraform fails unless instance type is t2.micro or t3.micro.

## Variable Flow (Environment -> Modules)

Defined in:

- infra/terraform/environments/dev/variables.tf

Passed in:

- infra/terraform/environments/dev/main.tf

Main variables you control:

- aws_region
- project_name
- vpc_cidr
- public_subnet_cidr
- availability_zone
- instance_type
- root_volume_size_gb
- free_tier_only
- allowed_ssh_cidrs
- allowed_public_http_cidrs
- allowed_nodeport_cidrs
- allowed_k8s_api_cidrs
- public_key_path

Example values:

- infra/terraform/environments/dev/terraform.tfvars.example

## Outputs You Get After Apply

File:

- infra/terraform/environments/dev/outputs.tf

Outputs:

- instance_public_ip
- instance_public_dns
- instance_id
- key_pair_name
- vpc_id
- public_subnet_id
- public_subnet_az
- security_group_id

How these are used next:

1. Use instance_public_ip to generate Ansible inventory.
2. Use SSH key + instance_public_ip to run bootstrap playbook.
3. Deploy k3s workloads after bootstrap.

## End-to-End Provisioning Flow

1. terraform init
- Downloads AWS provider.

2. terraform plan
- Shows exactly what resources will be created/changed.

3. terraform apply
- Creates VPC, subnet, route, security group, key pair, EC2.

4. terraform output -raw instance_public_ip
- Gives IP for Ansible inventory generation.

## Security Recommendation for Real Use

Before production-like testing, replace `0.0.0.0/0` CIDRs with your own public IP CIDR where possible, especially for:

- allowed_ssh_cidrs
- allowed_k8s_api_cidrs
