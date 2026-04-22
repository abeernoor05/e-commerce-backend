# E-Commerce Backend on AWS EC2 (Terraform + Ansible + k3s + ArgoCD)

Production-style microservices deployment for a cloud computing project. This repository demonstrates a complete DevOps pipeline from local development to public cloud access with CI/CD and GitOps.

## Project Objective

Deploy a microservices codebase to Amazon EC2 so the application is fully functional and reachable by external users.

This implementation includes:

- containerized services with Docker
- infrastructure as code with Terraform
- host bootstrap with Ansible
- orchestration with k3s Kubernetes
- CI with GitHub Actions
- CD and reconciliation with ArgoCD

## Application Services

- auth-service: signup, login, JWT-based identity endpoints
- product-service: product catalog and inventory operations
- order-service: order creation with product inventory validation

## Architecture Summary

1. Terraform provisions VPC, subnet, route/IGW, security group, and EC2 instance.
2. Ansible configures EC2 with Docker and k3s.
3. Kubernetes manifests deploy services in namespace ecommerce.
4. Services are exposed through NodePort for external testing.
5. GitHub Actions builds and pushes service images on every main push.
6. GitHub Actions updates deployment image tags to the commit SHA.
7. ArgoCD auto-syncs repository changes to the cluster.

## Repository Structure

- services: service source code and Dockerfiles
- infra/terraform: AWS provisioning modules and environment configs
- infra/ansible: host bootstrap roles and playbooks
- deploy/k8s: base manifests and overlays (Kustomize)
- deploy/argocd: ArgoCD application manifest
- .github/workflows: CI workflows
- scripts: helper scripts for inventory and demo testing
- docs: architecture notes and operational runbooks

## Prerequisites

Local machine tools:

- Docker and Docker Compose
- Terraform >= 1.5
- Ansible Core >= 2.14
- kubectl
- Python 3
- AWS credentials configured for Terraform

Cloud and platform accounts:

- AWS account with EC2/VPC permissions
- Docker Hub account and token
- GitHub repository with Actions enabled

GitHub secrets required:

- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN

## Quick Start Paths

- docs index: docs/README.md
- local test flow: docs/runbooks/local-testing.md
- full EC2 deployment flow: docs/runbooks/ec2-quickstart.md
- deployment operations and verification: docs/runbooks/deployment.md
- infrastructure deep dive: docs/architecture/terraform-infra.md
- service architecture details: docs/architecture/overview.md

## External Access Endpoints

After successful deployment and sync, services are reachable at:

- auth-service: http://<EC2_PUBLIC_IP>:30081/docs
- product-service: http://<EC2_PUBLIC_IP>:30082/docs
- order-service: http://<EC2_PUBLIC_IP>:30083/docs

## Demo Assets

- browser demo UI: demo/basic-ui.html
- scripted end-to-end flow: scripts/demo-user-flow.sh

The script validates:

1. health checks
2. signup and login
3. profile fetch
4. product creation
5. order creation and retrieval

## CI/CD Behavior

Workflow file: .github/workflows/ci.yml

On push to main (service code changes):

1. Build and push images for all services.
2. Update image tags in deploy/k8s/base/*/deployment.yaml.
3. Commit tag updates back to main.
4. ArgoCD detects new commit and syncs automatically.

## Security Notes

- SSH and Kubernetes API CIDRs should be restricted to your public IP whenever possible.
- NodePort range is open only as required for project external access validation.
- JWT is used for auth flow and passwords are hashed before storage.
- For production, move from SQLite to managed database (for example RDS), add TLS, and front services with ingress/load balancer.

## Cleanup

To remove cloud resources:

1. cd infra/terraform/environments/dev
2. terraform destroy

## License

For academic and demonstration use.
