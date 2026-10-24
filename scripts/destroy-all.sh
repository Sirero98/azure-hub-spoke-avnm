#!/usr/bin/env bash
# Destroys the stacks in reverse order. 00-foundation is kept.
# Usage: ./scripts/destroy-all.sh [-auto-approve]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKS=(60-test-vms 50-onprem-sim 40-avnm 20-firewall-rules 30-spokes 10-hub)

read -r -p "This will destroy ${#STACKS[@]} stacks. Type 'destroy' to continue: " answer
[[ "${answer}" == "destroy" ]] || { echo "Cancelled."; exit 1; }

for stack in "${STACKS[@]}"; do
  echo ""
  echo "=================== ${stack} ==================="
  "${SCRIPT_DIR}/tf.sh" "${stack}" destroy "$@"
done

echo ""
echo "✅ All stacks destroyed (00-foundation kept)."