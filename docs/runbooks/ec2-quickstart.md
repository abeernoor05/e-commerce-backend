# EC2 Single-Node Quickstart

This runbook provisions and deploys the full stack on one EC2 instance using Terraform, Ansible, and k3s.

## Prerequisites

- AWS credentials configured locally
- Terraform installed
- Ansible installed
- SSH key pair available at ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
- kubectl installed locally

## 1. Configure Terraform input values

```bash
cp infra/terraform/environments/dev/terraform.tfvars.example infra/terraform/environments/dev/terraform.tfvars
```

Recommended profile for this project:

- instance_type = m7i-flex.large
- free_tier_only = false
- root_volume_size_gb = 30

Lean alternative:

- instance_type = c7i-flex.large

Security recommendation:

- set allowed_ssh_cidrs to your public CIDR
- set allowed_k8s_api_cidrs to your public CIDR

## 2. Provision infrastructure with Terraform

```bash
cd infra/terraform/environments/dev
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Capture useful outputs:

```bash
terraform output -raw instance_public_ip
terraform output -raw instance_public_dns
terraform output security_group_id
```

## 3. Generate Ansible inventory

From repository root:

```bash
./scripts/render-ansible-inventory.sh <EC2_PUBLIC_IP> ~/.ssh/id_rsa ubuntu
```

## 4. Bootstrap EC2 host

```bash
ansible-playbook -i infra/ansible/inventory/hosts.ini infra/ansible/playbooks/bootstrap.yml
```

Bootstrap installs and configures:

- base OS packages
- Docker engine
- k3s single-node cluster

## 5. Configure kubeconfig locally

Fetch kubeconfig from EC2 and adjust server endpoint as needed:

```bash
mkdir -p ~/.kube
ssh -i ~/.ssh/id_rsa ubuntu@<EC2_PUBLIC_IP> "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config
```

If certificate SAN does not include your public IP, use SSH tunnel access to 127.0.0.1:16443.

## 6. Deploy workloads

```bash
kubectl apply -k deploy/k8s/overlays/dev
kubectl get pods -n ecommerce
kubectl get svc -n ecommerce
```

Expected services:

- auth-service NodePort 30081
- product-service NodePort 30082
- order-service NodePort 30083

## 7. Install and apply ArgoCD application

Install ArgoCD if not already present:

```bash
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Apply application manifest:

```bash
kubectl apply -f deploy/argocd/application.yaml
kubectl get applications -n argocd
```

Expected status: Synced Healthy.

## 8. Validate external access

From browser or curl:

- http://<EC2_PUBLIC_IP>:30081/docs
- http://<EC2_PUBLIC_IP>:30082/docs
- http://<EC2_PUBLIC_IP>:30083/docs

Optional scripted validation:

```bash
./scripts/demo-user-flow.sh <EC2_PUBLIC_IP>
```

## 9. Teardown (when demo period ends)

```bash
cd infra/terraform/environments/dev
terraform destroy
```
