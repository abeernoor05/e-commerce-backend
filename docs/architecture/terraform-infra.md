# Terraform Infrastructure Deep Dive

This document describes the infrastructure layer defined under infra/terraform and explains why each resource exists.

## Scope

Environment entrypoint:

- infra/terraform/environments/dev/main.tf

Composed modules:

- network
- security
- compute

## Network Module

Files:

- infra/terraform/modules/network/main.tf
- infra/terraform/modules/network/variables.tf
- infra/terraform/modules/network/outputs.tf

Managed resources:

1. VPC
- resource: aws_vpc.main
- purpose: isolated network boundary for project resources
- key setting: DNS support and DNS hostnames enabled

2. Public subnet
- resource: aws_subnet.public
- purpose: host EC2 instance with public internet routing
- key setting: map_public_ip_on_launch = true

3. Internet gateway
- resource: aws_internet_gateway.igw
- purpose: internet connectivity for subnet resources

4. Public route table and default route
- resources: aws_route_table.public, aws_route.public_internet
- purpose: route outbound traffic to internet gateway

5. Route table association
- resource: aws_route_table_association.public
- purpose: attach public route table to public subnet

## Security Module

Files:

- infra/terraform/modules/security/main.tf
- infra/terraform/modules/security/variables.tf
- infra/terraform/modules/security/outputs.tf

Managed resource:

1. Application security group
- resource: aws_security_group.app
- purpose: least-privilege inbound controls plus outbound egress

Ingress profile:

- tcp/22 (SSH) from allowed_ssh_cidrs
- tcp/80 and tcp/443 from allowed_public_http_cidrs
- tcp/6443 (k3s API) from allowed_k8s_api_cidrs
- tcp/30000-32767 (NodePort) from allowed_nodeport_cidrs

Egress profile:

- all outbound allowed to 0.0.0.0/0

## Compute Module

Files:

- infra/terraform/modules/compute/main.tf
- infra/terraform/modules/compute/variables.tf
- infra/terraform/modules/compute/outputs.tf

Managed resources and data:

1. SSH key pair registration
- resource: aws_key_pair.deployer
- purpose: allow SSH access with local public key

2. Ubuntu image lookup
- data source: data.aws_ami.ubuntu
- purpose: select current Ubuntu 22.04 LTS AMI automatically

3. EC2 instance
- resource: aws_instance.app_server
- purpose: single-node host for Docker and k3s workloads
- highlights:
  - configurable instance type
  - gp3 root volume with configurable size
  - IMDSv2 enforced
  - security group attachment from security module
  - public IP association through subnet configuration

Policy guard:

- if free_tier_only = true, only t2.micro or t3.micro are accepted

## Important Variables

Defined in:

- infra/terraform/environments/dev/variables.tf

Commonly adjusted values:

- aws_region
- instance_type
- root_volume_size_gb
- free_tier_only
- allowed_ssh_cidrs
- allowed_k8s_api_cidrs
- allowed_nodeport_cidrs
- public_key_path

Template values file:

- infra/terraform/environments/dev/terraform.tfvars.example

## Outputs and Their Use

Output definitions:

- infra/terraform/environments/dev/outputs.tf

Key outputs:

- instance_public_ip
- instance_public_dns
- instance_id
- security_group_id
- vpc_id
- public_subnet_id

Operational use:

1. instance_public_ip is used to generate Ansible inventory.
2. security_group_id helps verify open/closed ingress rules.
3. instance_public_dns is useful for browser and API testing.

## Standard Provisioning Lifecycle

1. terraform init
2. terraform plan
3. terraform apply
4. terraform output -raw instance_public_ip

## Production Hardening Recommendations

1. restrict SSH and Kubernetes API ingress to your own public CIDR
2. avoid broad NodePort exposure when not actively demoing
3. add AWS IAM roles and SSM Session Manager for improved access control
4. move to managed control plane and database for resilient production workloads
