#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <EC2_PUBLIC_IP> <SSH_PRIVATE_KEY_PATH> [SSH_USER]"
  echo "Example: $0 54.12.34.56 ~/.ssh/id_rsa ubuntu"
  exit 1
fi

EC2_IP="$1"
SSH_KEY_PATH="$2"
SSH_USER="${3:-ubuntu}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INVENTORY_FILE="$ROOT_DIR/infra/ansible/inventory/hosts.ini"

cat > "$INVENTORY_FILE" <<EOF
[app]
app-server ansible_host=${EC2_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY_PATH}
EOF

echo "Wrote inventory to: $INVENTORY_FILE"
cat "$INVENTORY_FILE"
