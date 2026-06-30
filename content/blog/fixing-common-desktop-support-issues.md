+++
title = "Fixing Common Desktop Support Issues"
date = 2026-06-05
summary = "A field guide to the recurring desktop support issues every K-12 IT pro sees, and how to fix them efficiently."
tags = ["desktop-support", "troubleshooting", "k12", "windows"]
+++

Desktop support in a K‑12 school is repetitive by nature. The same issues come back week after week. The goal is not to eliminate them — that is impossible — but to resolve them quickly and consistently so you can move on to the work that actually requires your attention.

## Issue 1: "My Printer Is Not Working"

Nine times out of ten:

1. The printer is off or offline — check the physical device first
2. The print spooler is stuck — restart it

```powershell
Restart-Service -Name Spooler -Force
```

3. The wrong printer is set as default — fix it in Settings > Devices > Printers

If it is a network printer, verify the IP has not changed. Static IPs or DHCP reservations prevent this.

## Issue 2: "I Cannot Log In"

Work through the checklist:

- Is the account locked? Check in Entra / AD
- Is the password expired? Reset it
- Is the device connected to the network? No network = no auth
- For shared devices: is the user selecting the right sign-in option? (Entra vs local)

## Issue 3: "My Computer Is Slow"

Before assuming hardware failure:

1. Check Task Manager for runaway processes
2. Check free disk space — under 10% will slow any machine
3. Clear temp files
4. Check for pending updates running in the background
5. Check startup programs — disable unnecessary ones

```powershell
# View startup programs
Get-CimInstance Win32_StartupCommand | Select-Object Name, Location
```

## Issue 4: "I Cannot Access My Files"

For OneDrive / SharePoint issues:

1. Check OneDrive sync status — is it signed in?
2. Check Files On-Demand settings — are files available offline?
3. Verify permissions in SharePoint or the M365 admin center
4. Check for sync conflicts — right-click OneDrive icon > View sync problems

## Issue 5: "The Internet Is Down"

Before touching anything:

1. Check the cable — physical connection first
2. Check the IP — `ipconfig` — is it APIPA (169.254.x.x)? That means no DHCP
3. Ping the gateway, then DNS, then an external site — isolate where it breaks
4. Check the switch port — is it active?
5. Check the firewall — is the user's device or VLAN blocked?

The pattern in all of these: start at layer 1 (physical) and work your way up. Spending two minutes checking the cable saves thirty minutes debugging network policy.
