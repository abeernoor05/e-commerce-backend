#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <EC2_PUBLIC_IP_OR_DNS>"
  echo "Example: $0 3.95.22.10"
  exit 1
fi

HOST="$1"
AUTH_BASE="http://${HOST}:30081"
PRODUCT_BASE="http://${HOST}:30082"
ORDER_BASE="http://${HOST}:30083"
EMAIL="demo+$(date +%s)@example.com"
PASSWORD="Passw0rd!"
FULL_NAME="Demo User"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required but not installed."
    exit 1
  fi
}

need_cmd curl
need_cmd python3

echo "1) Health checks"
curl -sS "${AUTH_BASE}/health" && echo
curl -sS "${PRODUCT_BASE}/health" && echo
curl -sS "${ORDER_BASE}/health" && echo

echo "2) Sign up user: ${EMAIL}"
SIGNUP_RESP="$(curl -sS -X POST "${AUTH_BASE}/auth/signup" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"full_name\":\"${FULL_NAME}\"}")"
echo "${SIGNUP_RESP}"

echo "3) Login user"
LOGIN_RESP="$(curl -sS -X POST "${AUTH_BASE}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}")"
echo "${LOGIN_RESP}"
TOKEN="$(printf '%s' "${LOGIN_RESP}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')"

echo "4) Verify /auth/me"
ME_RESP="$(curl -sS "${AUTH_BASE}/auth/me" -H "Authorization: Bearer ${TOKEN}")"
echo "${ME_RESP}"

echo "5) Create product"
PRODUCT_RESP="$(curl -sS -X POST "${PRODUCT_BASE}/products" \
  -H "Content-Type: application/json" \
  -d '{"name":"Demo Keyboard","description":"Mechanical keyboard","category":"electronics","price":99.99,"inventory_count":10}')"
echo "${PRODUCT_RESP}"
PRODUCT_ID="$(printf '%s' "${PRODUCT_RESP}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"

echo "6) Create order for product_id=${PRODUCT_ID}"
ORDER_RESP="$(curl -sS -X POST "${ORDER_BASE}/orders" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\":${PRODUCT_ID},\"quantity\":2}")"
echo "${ORDER_RESP}"
ORDER_ID="$(printf '%s' "${ORDER_RESP}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"

echo "7) Verify order"
curl -sS "${ORDER_BASE}/orders/${ORDER_ID}" && echo

echo "8) List orders"
curl -sS "${ORDER_BASE}/orders" && echo

echo "Done. Demo flow completed successfully."
