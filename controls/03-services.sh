#!/usr/bin/env bash
# 03-services.sh — disable unnecessary/insecure services (CIS 2.x).

disable_service() {
  local svc="$1"
  if systemctl is-enabled "${svc}" >/dev/null 2>&1; then
    record "2.2.x" "medium" "fail" "${svc} enabled"
    [[ "${DRY_RUN}" == "1" ]] || { systemctl disable --now "${svc}" >/dev/null 2>&1 || true; }
  else
    record "2.2.x" "medium" "pass" "${svc} disabled"
  fi
}

# Remove legacy/insecure services.
disable_service avahi-daemon
disable_service cups
disable_service nfs-server
disable_service rpcbind
disable_service vsftpd
disable_service tftp

# 2.2.1 — ensure a time sync service is enabled (chrony).
if systemctl is-active chronyd >/dev/null 2>&1; then
  record "2.2.1" "medium" "pass" "chronyd active"
else
  record "2.2.1" "medium" "fail" "chronyd not active"
  [[ "${DRY_RUN}" == "1" ]] || systemctl enable --now chronyd >/dev/null 2>&1 || true
fi
