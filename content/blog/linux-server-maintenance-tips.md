+++
title = "Useful Linux Server Maintenance Tips"
date = 2026-06-20
summary = "Practical maintenance tasks every Linux sysadmin should be doing on a regular basis."
tags = ["linux", "sysadmin", "maintenance", "debian"]
+++

Server maintenance is not glamorous, but it is the difference between a stable environment and 2 AM phone calls. Here is a checklist of tasks I run on my Debian servers — at work and at home — to keep things healthy.

## 1. Keep Packages Updated

Security patches are not optional. Set up unattended-upgrades for critical packages and review the rest weekly.

```bash
# Check for available updates
sudo apt update && apt list --upgradable

# Apply updates
sudo apt upgrade

# Remove unused dependencies
sudo apt autoremove
```

## 2. Monitor Disk Space

A full disk will take down services faster than almost anything else. Check regularly:

```bash
df -h
```

Watch `/boot` separately — old kernels can fill it up. Remove unused kernels with:

```bash
sudo apt autoremove --purge
```

## 3. Review Logs

Logs tell you what is about to break before it breaks. Focus on:

```bash
# System journal — recent errors
journalctl -p err --since "24 hours ago"

# Failed services
systemctl --failed

# Authentication attempts
journalctl -u ssh --since today
```

## 4. Check Running Services

Periodically audit what is running. If a service does not need to be there, disable it.

```bash
systemctl list-unit-files --type=service --state=enabled
```

## 5. Verify Backups

A backup you have never tested is not a backup. Pick a file, restore it, and confirm it works. Do this monthly at minimum.

## 6. Audit User Accounts

Remove accounts that no longer need access. Stale accounts are a security risk.

```bash
# List users with login shells
grep '/bin/bash\|/bin/sh' /etc/passwd

# Check last login times
lastlog | grep -v "Never"
```

These six tasks take maybe thirty minutes per server and prevent the vast majority of preventable outages. Consistency matters more than perfection.
