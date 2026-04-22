# Deployment Runbook

This runbook is the operational reference for deploy, validate, and update workflows in this repository.

See also:

- docs/runbooks/ec2-quickstart.md for initial environment creation
- docs/runbooks/local-testing.md for pre-cloud validation

## Deployment Profile

Preferred instance profile:

- instance_type = m7i-flex.large
- root_volume_size_gb = 30
- free_tier_only = false

Alternative cost profile:

- instance_type = c7i-flex.large

## A. Initial Infrastructure and Cluster Deployment

1. Provision infrastructure

```bash
cd infra/terraform/environments/dev
terraform init
terraform apply
```

2. Bootstrap host

```bash
cd /home/abeer03/Cloud-Computing
./scripts/render-ansible-inventory.sh <EC2_PUBLIC_IP> ~/.ssh/id_rsa ubuntu
ansible-playbook -i infra/ansible/inventory/hosts.ini infra/ansible/playbooks/bootstrap.yml
```

3. Deploy Kubernetes manifests

```bash
kubectl apply -k deploy/k8s/overlays/dev
kubectl get pods -n ecommerce
kubectl get svc -n ecommerce
```

4. Deploy ArgoCD application

```bash
kubectl apply -f deploy/argocd/application.yaml
kubectl get applications -n argocd
```

## B. CI/CD Update Flow

1. Push code changes to main.
2. GitHub Actions workflow .github/workflows/ci.yml runs:
- builds and pushes Docker images
- updates Kubernetes image tags in deploy/k8s/base/*/deployment.yaml
- commits updated image tags back to main
3. ArgoCD detects repository change and syncs cluster state.

## C. Verification Checklist

Run after each deployment or update:

```bash
kubectl get applications -n argocd
kubectl get application ecommerce-dev -n argocd -o jsonpath='{.status.sync.status}{" "}{.status.health.status}{"\n"}'
kubectl get pods -n ecommerce
kubectl get svc -n ecommerce
```

Expected:

- application status: Synced Healthy
- pods: Running
- service ports include 30081, 30082, 30083

## D. External Validation

```bash
curl -sS http://<EC2_PUBLIC_IP>:30081/health
curl -sS http://<EC2_PUBLIC_IP>:30082/health
curl -sS http://<EC2_PUBLIC_IP>:30083/health
```

Or run scripted end-to-end validation:

```bash
./scripts/demo-user-flow.sh <EC2_PUBLIC_IP>
```

## E. Rollback and Recovery

1. If sync fails, inspect ArgoCD application events and Kubernetes pod logs.
2. Revert problematic commit in Git and push revert.
3. ArgoCD reconciles to reverted manifest state automatically.

## F. Environment Teardown

```bash
cd infra/terraform/environments/dev
terraform destroy
```
