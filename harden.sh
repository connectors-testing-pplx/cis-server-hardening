#!/usr/bin/env bash
#
# harden.sh — apply, audit, or dry-run CIS Benchmark hardening controls.
#
# Usage:
#   sudo ./harden.sh [--dry-run] [apply|audit] [--profile <file>]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/audit.sh
. "${SCRIPT_DIR}/lib/audit.sh"

MODE="apply"
DRY_RUN=0
PROFILE="${SCRIPT_DIR}/profiles/level1-server.profile"

while [[ $# -gt 0 ]]; do
  case "$1" in
    apply|audit) MODE="$1"; shift ;;
    --dry-run)   DRY_RUN=1; shift ;;
    --profile)  PROFILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [apply|audit] [--profile <file>]"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

require_root
detect_platform
load_profile "${PROFILE}"

REPORTS_DIR="${SCRIPT_DIR}/reports"
mkdir -p "${REPORTS_DIR}"
REPORT="${REPORTS_DIR}/audit-$(date +%Y%m%d-%H%M%S).txt"
init_report "${REPORT}"

CONTROL_DIR="${SCRIPT_DIR}/controls"
mapfile -t CONTROLS < <(find "${CONTROL_DIR}" -maxdepth 1 -name '*.sh' | sort)

for ctrl in "${CONTROLS[@]}"; do
  log "Running control: $(basename "${ctrl}")"
  # shellcheck source=/dev/null
  ( DRY_RUN="${DRY_RUN}" MODE="${MODE}" . "${ctrl}" )
done

summarize_report
log "Done. Report: ${REPORT}"
