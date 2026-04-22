# Cloud Computing Project 03

Scalable e-commerce backend with DevOps automation.

## Services
- auth-service: signup/login with JWT
- product-service: products, categories, inventory
- order-service: create and track orders, validates stock via product-service

## Stack
- Docker for containerization
- Terraform for AWS provisioning
- Ansible for server bootstrap
- Kubernetes (k3s) for orchestration
- GitHub Actions + ArgoCD for CI/CD

## Cost Guardrails
- Default deployment profile is `m7i-flex.large` with a 30 GB gp3 root volume for k3s + 3 services.
- If you want a leaner profile, switch to `c7i-flex.large`.
- Optional free-tier mode is still supported by setting `free_tier_only = true` with `t2.micro` or `t3.micro`.

## Repository Layout
- services/: microservices source code
- infra/terraform/: infrastructure as code
- infra/ansible/: configuration management
- deploy/k8s/: kubernetes manifests (kustomize)
- deploy/argocd/: gitops app definition
- .github/workflows/: CI automation
- docs/: architecture and runbooks

## Suggested Build Order
1. Implement services locally
2. Containerize each service
3. Stand up infra via Terraform
4. Bootstrap VM via Ansible
5. Deploy manifests to k3s
6. Wire CI and ArgoCD

## Quickstart
- EC2 single-node path: `docs/runbooks/ec2-quickstart.md`
- Local integration path: `docs/runbooks/local-testing.md`
- Terraform infra deep dive: `docs/architecture/terraform-infra.md`
