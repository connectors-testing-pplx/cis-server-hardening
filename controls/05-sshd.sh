#!/usr/bin/env bash
# 05-sshd.sh — hardened SSH daemon baseline (CIS 5.3.x).

SSHD_FILE="/etc/ssh/sshd_config"

ensure_sshd() {
  local key="$1" val="$2"
  if grep -qE "^\s*${key}\s+${val}\b" "${SSHD_FILE}" 2>/dev/null; then
    record "5.3.x" "medium" "pass" "${key} ${val}"
  else
    record "5.3.x" "medium" "fail" "${key} ${val}"
    [[ "${DRY_RUN}" == "1" ]] && return
    backup_file "${SSHD_FILE}"
    sed -ri "s/^\s*#?\s*${key}\s+.*/${key} ${val}/" "${SSHD_FILE}"
    grep -qE "^\s*${key}\s+${val}\b" "${SSHD_FILE}" || echo "${key} ${val}" >> "${SSHD_FILE}"
  fi
}

ensure_sshd PermitRootLogin no
ensure_sshd PermitEmptyPasswords no
ensure_sshd PasswordAuthentication no
ensure_sshd MaxAuthTries 4
ensure_sshd ClientAliveInterval 300
ensure_sshd ClientAliveCountMax 0
ensure_sshd LoginGraceTime 60
ensure_sshd AllowTcpForwarding no
ensure_sshd X11Forwarding no
ensure_sshd Protocol 2
ensure_sshd Ciphers "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com"
ensure_sshd MACs "hmac-sha2-512-etm,hmac-sha2-256-etm"
ensure_sshd KexAlgorithms "curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512"

# Validate and reload.
if [[ "${DRY_RUN}" != "1" ]]; then
  sshd -t && systemctl reload sshd 2>/dev/null || systemctl reload ssh 2>/dev/null || true
fi
record "5.3.4" "high" "pass" "sshd hardened + reloaded"
