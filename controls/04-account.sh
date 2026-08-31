#!/usr/bin/env bash
# 04-account.sh — password policy, lockout, and umask (CIS 5.4.x, 6.x).

PAM_FILE="/etc/pam.d/common-auth"
[[ -f /etc/pam.d/system-auth ]] && PAM_FILE="/etc/pam.d/system-auth"

# 5.4.1 — password retry / lockout.
if grep -q 'pam_faillock' "${PAM_FILE}" 2>/dev/null; then
  record "5.4.1" "medium" "pass" "pam_faillock configured"
else
  record "5.4.1" "medium" "fail" "pam_faillock missing"
  [[ "${DRY_RUN}" == "1" ]] || {
    backup_file "${PAM_FILE}"
    printf 'auth required pam_faillock.so preauth silent deny=5 unlock_time=900\n' >> "${PAM_FILE}"
  }
fi

# 5.4.2 — password quality (pam_pwquality / cracklib).
QUAL_FILE="/etc/security/pwquality.conf"
if [[ -f "${QUAL_FILE}" ]]; then
  backup_file "${QUAL_FILE}"
  record "5.4.2" "medium" "pass" "pwquality present"
  [[ "${DRY_RUN}" == "1" ]] || {
    set_config "${QUAL_FILE}" minlen 14
    set_config "${QUAL_FILE}" minclass 4
    set_config "${QUAL_FILE}" dcredit -1
    set_config "${QUAL_FILE}" ucredit -1
    set_config "${QUAL_FILE}" ocredit -1
    set_config "${QUAL_FILE}" lcredit -1
  }
else
  record "5.4.2" "medium" "fail" "pwquality.conf missing"
fi

# 5.4.3 — default umask 027 in login defs.
ensure_login_def() {
  local key="$1" val="$2"
  if grep -qE "^${key}\s+${val}\b" /etc/login.defs; then
    record "5.4.3" "low" "pass" "${key}=${val}"
  else
    record "5.4.3" "low" "fail" "${key}!=${val}"
    [[ "${DRY_RUN}" == "1" ]] || set_config /etc/login.defs "${key}" "${val}"
  fi
}
ensure_login_def UMASK 027
ensure_login_def PASS_MAX_DAYS 90
ensure_login_def PASS_MIN_DAYS 1
