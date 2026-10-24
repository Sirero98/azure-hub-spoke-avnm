   #!/usr/bin/env bash
   # Wrapper de Terraform para los stacks del proyecto.
   # Uso:     ./scripts/tf.sh <stack> <comando> [args...]
   # Ejemplo: ./scripts/tf.sh 10-hub plan
   #          ./scripts/tf.sh 40-avnm apply -auto-approve

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Uso: $0 <stack> <comando> [argumentos extra...]" >&2
  echo "Ejemplo: $0 10-hub plan" >&2
  exit 1
fi

STACK="$1"
COMMAND="$2"
shift 2

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_DIR="${ROOT_DIR}/stacks/${STACK}"

if [[ ! -d "${STACK_DIR}" ]]; then
  echo "Error: el stack '${STACK}' no existe." >&2
  echo "Stacks disponibles: $(ls "${ROOT_DIR}/stacks" | tr '\n' ' ')" >&2
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
    echo ">> terraform ${COMMAND} en ${STACK}"
    terraform "${COMMAND}" -var-file="${COMMON_VARS}" "$@"
    ;;
  *)
    terraform "${COMMAND}" "$@"
    ;;
esac