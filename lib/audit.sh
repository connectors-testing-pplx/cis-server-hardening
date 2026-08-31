#!/usr/bin/env bash
# lib/audit.sh — control status reporting helpers.

REPORT_FILE=""

init_report() {
  REPORT_FILE="$1"
  : > "${REPORT_FILE}"
  {
    echo "CIS Hardening Audit Report"
    echo "Host: $(hostname)   Date: $(date -Iseconds)"
    echo "Mode: ${MODE:-apply}   Dry-run: ${DRY_RUN:-0}"
    echo "============================================"
    printf '%-12s %-10s %-8s %s\n' "CIS-ID" "SEVERITY" "STATUS" "CONTROL"
  } >> "${REPORT_FILE}"
}

# record <cis_id> <severity> <status(pass|fail)> <description>
record() {
  [[ -n "${REPORT_FILE}" ]] || return 0
  printf '%-12s %-10s %-8s %s\n' "$1" "$2" "$3" "$4" >> "${REPORT_FILE}"
}

summarize_report() {
  [[ -n "${REPORT_FILE}" ]] || return 0
  local pass fail
  pass=$(grep -c '\bpass\b' "${REPORT_FILE}" || true)
  fail=$(grep -c '\bfail\b' "${REPORT_FILE}" || true)
  {
    echo "============================================"
    echo "Summary: ${pass} pass, ${fail} fail"
  } >> "${REPORT_FILE}"
}
