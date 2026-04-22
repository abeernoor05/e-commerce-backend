#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <SSH_PRIVATE_KEY_PATH> [SSH_USER]"
  echo "Example: $0 ~/.ssh/id_rsa ubuntu"
  exit 1
fi

SSH_KEY_PATH="$1"
SSH_USER="${2:-ubuntu}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$ROOT_DIR/infra/terraform/environments/dev"

EC2_IP="$(cd "$TF_DIR" && terraform output -raw instance_public_ip)"

"$SCRIPT_DIR/render-ansible-inventory.sh" "$EC2_IP" "$SSH_KEY_PATH" "$SSH_USER"
