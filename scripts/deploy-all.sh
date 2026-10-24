#!/usr/bin/env bash
# Deploys all stacks in order, one after another.
# Usage: ./scripts/deploy-all.sh [-auto-approve]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKS=(00-foundation 10-hub 20-firewall-rules 30-spokes 40-avnm 50-onprem-sim 60-test-vms)

for stack in "${STACKS[@]}"; do
  echo ""
  echo "=================== ${stack} ==================="
  "${SCRIPT_DIR}/tf.sh" "${stack}" init -input=false
  "${SCRIPT_DIR}/tf.sh" "${stack}" apply "$@"
done

echo ""
echo "✅ All stacks deployed."