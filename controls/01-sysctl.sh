#!/usr/bin/env bash
# 01-sysctl.sh — kernel and network stack hardening (CIS 3.x).
# Controls sourced with DRY_RUN and MODE in the environment.

ensure_sysctl() {
  local key="$1" want="$2"
  local have
  have="$(sysctl -n "${key}" 2>/dev/null || echo "?")"
  if [[ "${have}" == "${want}" ]]; then
    record "3.1.x" "low" "pass" "${key}=${want}"
    return
  fi
  record "3.1.x" "low" "fail" "${key}=${want} (was ${have})"
  [[ "${DRY_RUN}" == "1" ]] && return
  sysctl -w "${key}=${want}" >/dev/null
  grep -qE "^${key}" /etc/sysctl.d/99-cis.conf 2>/dev/null \
    || echo "${key}=${want}" >> /etc/sysctl.d/99-cis.conf
}

ensure_sysctl net.ipv4.ip_forward 0
ensure_sysctl net.ipv4.conf.all.send_redirects 0
ensure_sysctl net.ipv4.conf.default.send_redirects 0
ensure_sysctl net.ipv4.conf.all.accept_redirects 0
ensure_sysctl net.ipv4.conf.default.accept_redirects 0
ensure_sysctl net.ipv4.conf.all.accept_source_route 0
ensure_sysctl net.ipv4.conf.default.accept_source_route 0
ensure_sysctl net.ipv4.conf.all.log_martians 1
ensure_sysctl net.ipv4.conf.default.log_martians 1
ensure_sysctl net.ipv4.tcp_syncookies 1
ensure_sysctl net.ipv6.conf.all.disable_ipv6 1
ensure_sysctl net.ipv6.conf.default.disable_ipv6 1

# 3.4.1 — blacklist uncommon network protocols.
if [[ "${DRY_RUN}" != "1" ]]; then
  for proto in dccp sctp rds tipc; do
    echo "install ${proto} /bin/true" > "/etc/modprobe.d/${proto}.conf"
  done
fi
record "3.4.1" "medium" "pass" "blacklisted dccp/sctp/rds/tipc"
