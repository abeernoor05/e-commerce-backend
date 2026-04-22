# Architecture Overview

This document describes the current logical architecture for the e-commerce backend platform.

## System Components

### 1. Application Layer

- auth-service
- product-service
- order-service

All services are implemented with FastAPI and run as independent containers.

### 2. Data Layer

- each service owns its own SQLite database file
- no direct database access between services
- service-to-service communication occurs over HTTP APIs

### 3. Infrastructure Layer

- Amazon VPC with one public subnet
- EC2 instance as single-node compute host
- security group for SSH, HTTP/HTTPS, Kubernetes API, and NodePort access

### 4. Platform Layer

- k3s as the Kubernetes distribution on EC2
- Kustomize for manifest composition (base + dev overlay)
- ArgoCD for GitOps reconciliation

### 5. Delivery Layer

- GitHub Actions builds and pushes images to Docker Hub
- GitHub Actions updates Kubernetes deployment image tags
- ArgoCD auto-sync applies those manifest changes to the cluster

## Service Responsibilities

### auth-service

- user signup
- user login
- JWT issue and token-based identity check

### product-service

- product creation and listing
- inventory updates and stock checks
- inventory reservation endpoint used by order-service

### order-service

- order creation
- order retrieval and listing
- stock validation and reservation via product-service

## Request Flow (Order Creation)

1. Client sends POST /orders to order-service.
2. order-service requests availability from product-service.
3. If stock is available, order-service requests product reservation.
4. order-service writes confirmed order to its database.
5. order-service returns order payload to client.

## Kubernetes Topology

- namespace: ecommerce
- one Deployment + one Service per microservice
- probes enabled on /health for liveness/readiness
- Service types:
	- NodePort for external project demonstration
	- internal service DNS for inter-service calls

## CI/CD and GitOps Flow

1. Developer pushes code to main.
2. GitHub Actions builds and pushes service images.
3. Workflow updates image tags in deployment manifests to commit SHA.
4. Workflow commits manifest changes to main.
5. ArgoCD detects repository drift and syncs to cluster.
6. Kubernetes rolls out new pods with new image tags.

## Security Boundaries

- external traffic enters through EC2 public IP and NodePort services
- Kubernetes API access is controlled by security group CIDRs
- SSH access is restricted by configurable CIDR list
- application authentication is token-based (JWT)

## Known Limitations

- single-node cluster (no high availability)
- SQLite is suitable for demo workloads only
- no TLS termination in current baseline setup

## Recommended Next Enhancements

1. add ingress controller and TLS certificates
2. migrate to managed relational database
3. add observability stack (metrics, logs, tracing)
4. split environments (dev/stage/prod) with isolated overlays
