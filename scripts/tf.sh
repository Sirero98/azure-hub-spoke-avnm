#!/usr/bin/env bash
# Terraform wrapper for the project stacks.
# Usage:   ./scripts/tf.sh <stack> <command> [args...]
# Example: ./scripts/tf.sh 10-hub plan
#          ./scripts/tf.sh 40-avnm apply -auto-approve
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <stack> <command> [extra args...]" >&2
  echo "Example: $0 10-hub plan" >&2
  exit 1
fi

STACK="$1"
COMMAND="$2"
shift 2

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_DIR="${ROOT_DIR}/stacks/${STACK}"

if [[ ! -d "${STACK_DIR}" ]]; then
  echo "Error: stack '${STACK}' does not exist." >&2
  echo "Available stacks: $(ls "${ROOT_DIR}/stacks" | tr '\n' ' ')" >&2
  exit 1
fi

cd "${STACK_DIR}"

CONFIG_DIR="${ROOT_DIR}/config"
COMMON_VARS="${CONFIG_DIR}/common.tfvars"
BACKEND_KEY="hubspoke/${STACK}.tfstate"

case "${COMMAND}" in
  init)
    echo ">> terraform init (key=${BACKEND_KEY})"
    terraform init \
      -backend-config="${CONFIG_DIR}/backend.hcl" \
      -backend-config="key=${BACKEND_KEY}" \
      "$@"
    ;;
  plan|apply|destroy|console|import)
    echo ">> terraform ${COMMAND} on ${STACK}"
    terraform "${COMMAND}" -var-file="${COMMON_VARS}" "$@"
    ;;
  *)
    terraform "${COMMAND}" "$@"
    ;;
esac