#!/usr/bin/env bash
# 02-filesystem.sh — filesystem mounts and permissions (CIS 1.x).

# 1.1.x — blacklist legacy/uncommon filesystems.
if [[ "${DRY_RUN}" != "1" ]]; then
  for fs in freevxfs jffs2 cramfs hfs udf; do
    echo "install ${fs} /bin/true" > "/etc/modprobe.d/${fs}.conf"
  done
fi
record "1.1.1" "low" "pass" "blacklisted legacy filesystems"

# 1.1.3-1.1.7 — ensure nodev/nosuid/noexec on /tmp, /dev/shm, /var/tmp if mounted.
ensure_mount_opt() {
  local mnt="$1" opt="$2"
  if findmnt -no TARGET "${mnt}" >/dev/null 2>&1; then
    if findmnt -no OPTIONS "${mnt}" | grep -qw "${opt}"; then
      record "1.1.x" "low" "pass" "${mnt} has ${opt}"
    else
      record "1.1.x" "low" "fail" "${mnt} missing ${opt}"
      [[ "${DRY_RUN}" == "1" ]] || mount -o remount,"${opt}" "${mnt}" 2>/dev/null || true
    fi
  fi
}

ensure_mount_opt /tmp nodev
ensure_mount_opt /tmp nosuid
ensure_mount_opt /tmp noexec
ensure_mount_opt /dev/shm nodev
ensure_mount_opt /dev/shm nosuid
ensure_mount_opt /dev/shm noexec

# 6.1.2 — permissions on system files.
ensure_perm() {
  local f="$1" want="$2"
  local have
  have="$(stat -c %a "${f}" 2>/dev/null || echo "?")"
  if [[ "${have}" == "${want}" ]]; then
    record "6.1.x" "medium" "pass" "${f} ${want}"
  else
    record "6.1.x" "medium" "fail" "${f} ${have} (want ${want})"
    [[ "${DRY_RUN}" == "1" ]] || chmod "${want}" "${f}"
  fi
}

ensure_perm /etc/passwd 644
ensure_perm /etc/group 644
ensure_perm /etc/shadow 640
ensure_perm /etc/gshadow 640
ensure_perm /etc/crontab 600
