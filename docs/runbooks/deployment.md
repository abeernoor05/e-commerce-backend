# Deployment Runbook

See also: `docs/runbooks/ec2-quickstart.md` for the fastest EC2-only setup path.

0. Free-tier policy
- Primary profile for this project is `instance_type = "m7i-flex.large"`, `free_tier_only = false`, and `root_volume_size_gb = 30`.
- Leaner alternative is `instance_type = "c7i-flex.large"`.
- If needed, free-tier mode remains available by setting `free_tier_only = true` and using `t2.micro`/`t3.micro`.

1. Provision infra
- cd infra/terraform/environments/dev
- terraform init && terraform apply

2. Configure server
- Generate infra/ansible/inventory/hosts.ini using:
- ./scripts/render-ansible-inventory.sh <EC2_PUBLIC_IP> ~/.ssh/id_rsa ubuntu
- ansible-playbook -i infra/ansible/inventory/hosts.ini infra/ansible/playbooks/bootstrap.yml

3. Deploy workloads
- kubectl apply -k deploy/k8s/overlays/dev

4. GitOps
- Apply deploy/argocd/application.yaml into ArgoCD namespace
