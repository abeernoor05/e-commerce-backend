# EC2 Single-Node Quickstart

This project runs on one EC2 machine with k3s installed on that same machine.

## 1. Prepare Terraform variables

Create a local variables file from the example:

- `cp infra/terraform/environments/dev/terraform.tfvars.example infra/terraform/environments/dev/terraform.tfvars`

Recommended profile:

- `instance_type = "m7i-flex.large"`
- `free_tier_only = false`
- `root_volume_size_gb = 30`

Alternative profile:

- `instance_type = "c7i-flex.large"`

Recommended security tightening:

- Set `allowed_ssh_cidrs` to your own public IP CIDR instead of `0.0.0.0/0`.
- Set `allowed_k8s_api_cidrs` to your own public IP CIDR.

## 2. Provision EC2 with Terraform

- `cd infra/terraform/environments/dev`
- `terraform init`
- `terraform plan -out tfplan`
- `terraform apply tfplan`

Capture public IP:

- `terraform output -raw instance_public_ip`

Optional useful outputs:

- `terraform output -raw instance_public_dns`
- `terraform output vpc_id`
- `terraform output security_group_id`

## 3. Generate Ansible inventory

From repository root:

- `./scripts/render-ansible-inventory.sh <EC2_PUBLIC_IP> ~/.ssh/id_rsa ubuntu`

## 4. Bootstrap EC2 with Ansible

From repository root:

- `ansible-playbook -i infra/ansible/inventory/hosts.ini infra/ansible/playbooks/bootstrap.yml`

This installs:

- base packages
- Docker
- k3s

## 5. Deploy Kubernetes manifests

- `kubectl apply -k deploy/k8s/overlays/dev`

## Notes

- "Local Kubernetes" in this project means local to the EC2 instance (single-node k3s), not local to your laptop.
- You can keep this setup for project completion, then migrate to EKS/RDS as an extension.
