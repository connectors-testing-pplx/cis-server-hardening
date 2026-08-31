# Level 1 Server profile — toggles and overrides for the hardening script.
# Source by lib/common.sh:load_profile.

CIS_LEVEL="1"
HOST_TYPE="server"

# Service toggles (1 = check/enforce, 0 = skip).
CONTROL_SYSCTL=1
CONTROL_FILESYSTEM=1
CONTROL_SERVICES=1
CONTROL_ACCOUNT=1
CONTROL_SSHD=1

# Time sync backend.
TIME_SYNC_DAEMON="chrony"
