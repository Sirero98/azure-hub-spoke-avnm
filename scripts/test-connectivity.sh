#!/usr/bin/env bash
# Connectivity tests for the hub-and-spoke lab.
# Runs curl from inside the VMs with 'az vm run-command' (no SSH needed)
# and compares each result with the expected firewall behaviour.
# Usage: ./scripts/test-connectivity.sh
set -euo pipefail

RG="rg-hubspoke-lab"
CURL="curl -sf -o /dev/null --max-time 5"
PASS=0
FAIL=0

# run_test <description> <source-vm> <command> <expected: ok|blocked>
run_test() {
  local description="$1" vm="$2" cmd="$3" expected="$4"
  local output result

  output=$(az vm run-command invoke -g "${RG}" -n "${vm}" \
    --command-id RunShellScript \
    --scripts "${cmd} && echo RESULT=ok || echo RESULT=blocked" \
    --query "value[0].message" -o tsv 2>/dev/null || true)
  result=$(grep -o 'RESULT=[a-z]*' <<< "${output}" | cut -d= -f2 || true)

  if [[ "${result}" == "${expected}" ]]; then
    echo "✅ PASS  ${description}  (expected: ${expected})"
    PASS=$((PASS + 1))
  else
    echo "❌ FAIL  ${description}  (expected: ${expected}, got: ${result:-error})"
    FAIL=$((FAIL + 1))
  fi
}

echo "== 1. Health: nginx listening on 8080 in every VM =="
for vm in vm-prod-1 vm-prod-2 vm-nonprod-1 vm-nonprod-2 vm-onprem; do
  run_test "nginx on ${vm}" "${vm}" "${CURL} http://localhost:8080" ok
done

echo ""
echo "== 2. East-west traffic through the firewall =="
run_test "prod-1    → prod-2       :8080 (same env)"        vm-prod-1    "${CURL} http://10.102.1.4:8080" ok
run_test "nonprod-1 → nonprod-2    :8080 (same env)"        vm-nonprod-1 "${CURL} http://10.104.1.4:8080" ok
run_test "prod-1    → nonprod-1    :8080 (exception)"       vm-prod-1    "${CURL} http://10.103.1.4:8080" ok
run_test "prod-2    → nonprod-1    :8080 (deny prod→np)"    vm-prod-2    "${CURL} http://10.103.1.4:8080" blocked
run_test "nonprod-1 → prod-1       :8080 (deny np→prod)"    vm-nonprod-1 "${CURL} http://10.101.1.4:8080" blocked

echo ""
echo "== 3. Hybrid traffic over the VPN =="
run_test "onprem    → prod-1       :8080"                   vm-onprem    "${CURL} http://10.101.1.4:8080" ok
run_test "prod-1    → onprem       :8080"                   vm-prod-1    "${CURL} http://192.168.1.4:8080" ok

echo ""
echo "== 4. Internet egress through the firewall =="
run_test "prod-1    → internet     :443"                    vm-prod-1    "${CURL} https://www.microsoft.com" ok

echo ""
echo "Passed: ${PASS}   Failed: ${FAIL}"
[[ ${FAIL} -eq 0 ]]