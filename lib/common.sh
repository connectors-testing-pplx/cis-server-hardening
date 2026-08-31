#!/usr/bin/env bash
# lib/common.sh — shared logging, platform detection, profile loader.

LOG_TAG="cis-harden"
log() { logger -t "${LOG_TAG}" -- "$*" 2>/dev/null || echo "[${LOG_TAG}] $*"; }

require_root() {
  [[ "$(id -u)" -eq 0 ]] || { echo "must run as root" >&2; exit 1; }
}

detect_platform() {
  PLATFORM_FAMILY="unknown"
  if [[ -f /etc/redhat-release ]]; then
    PLATFORM_FAMILY="redhat"
  elif [[ -f /etc/debian_version ]]; then
    PLATFORM_FAMILY="debian"
  fi
  export PLATFORM_FAMILY
}

# Back up a file before modifying it (once).
backup_file() {
  local f="$1"
  if [[ -f "${f}" && ! -f "${f}.cis.bak" ]]; then
    cp -a "${f}" "${f}.cis.bak"
  fi
}

# Apply a key=value setting in a config file (idempotent).
set_config() {
  local file="$1" key="$2" value="$3"
  backup_file "${file}"
  if grep -qE "^\s*${key}\s*=" "${file}" 2>/dev/null; then
    sed -ri "s|^\s*${key}\s*=.*|${key} = ${value}|" "${file}"
  else
    printf '%s = %s\n' "${key}" "${value}" >> "${file}"
  fi
}

load_profile() {
  local p="$1"
  [[ -f "${p}" ]] || { echo "profile not found: ${p}" >&2; exit 2; }
  # shellcheck source=/dev/null
  . "${p}"
}
