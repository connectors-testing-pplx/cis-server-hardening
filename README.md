# cis-server-hardening

A shell-based implementation of CIS Benchmark controls for Linux servers. Runs as an idempotent hardening script that applies a defensible security baseline, then produces an audit report mapping every change to a CIS control ID. Supports dry-run mode and per-control toggling via a profile.

## What it does

- Enforces kernel and network stack hardening (`sysctl` controls)
- Locks down boot parameters and removes legacy filesystems
- Configures `systemd-journald` and `logrotate` for audit retention
- Restrict file permissions on key system files (`/etc/passwd`, cron, at)
- Disable unused services and protocols (NFS, rsh, TFTP, IPv6 if not needed)
- Enforce password quality and account lockout policies
- Configure `sshd` to a hardened baseline (no root, ciphers, MACs, key-only)
- Generate a CIS-style audit report (pass/fail per control)

## Repository layout

```
cis-server-hardening/
├── harden.sh                # main entrypoint (apply | audit | dry-run)
├── controls/
│   ├── 01-sysctl.sh         # kernel + network hardening
│   ├── 02-filesystem.sh    # filesystem mounts & permissions
│   ├── 03-services.sh      # disable unnecessary services
│   ├── 04-account.sh       # password policy, lockout, umask
│   └── 05-sshd.sh           # SSH daemon hardening
├── profiles/
│   └── level1-server.profile
├── lib/
│   ├── audit.sh            # control status reporting helpers
│   └── common.sh           # shared logging + platform detection
└── reports/
    └── .gitkeep
```

## Usage

```bash
# Preview what would change (no writes)
sudo ./harden.sh --dry-run

# Apply the Level 1 server profile
sudo ./harden.sh apply --profile profiles/level1-server.profile

# Generate an audit report only (read-only)
sudo ./harden.sh audit
```

## Output

After a run, `reports/audit-<timestamp>.txt` lists each control with its CIS ID, severity, and pass/fail status — suitable for compliance evidence.

## Sample controls applied

| CIS ID      | Control                                    | Action                        |
|-------------|--------------------------------------------|------------------------------|
| 1.1.1       | Disable freevxfs / jffs2 / cramfs          | modprobe blacklists          |
| 1.3.1       | Ensure AIDE is installed                   | package + init db            |
| 2.2.1       | Time sync (chrony)                         | install + enable             |
| 3.4.1       | Disable DCCP / SCTP / RDS / TIPC           | modprobe blacklists          |
| 4.2.1       | journald persistent storage                | Storage=persistent           |
| 5.3.1       | sshd: MaxAuthTries 4                        | config + reload              |
| 5.3.4       | sshd: strong ciphers/MACs/KexAlgorithms   | config + reload              |
| 6.1.2       | Permissions on /etc/passwd 0644           | chmod                         |
| 6.2.6       | No empty password fields                   | audit + remediate            |

## Notes

- The script is idempotent: re-running leaves an already-hardened system unchanged.
- A `backup/` of original config files is created before any modification.
- Level 2 (more restrictive) controls live in `profiles/level2-server.profile` (extended).
