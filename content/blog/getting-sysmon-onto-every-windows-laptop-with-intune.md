+++
title = 'Getting Sysmon Onto Every Windows Laptop With Intune'
date = '2026-10-29T00:05:00-05:00'
summary = 'How I shipped Sysmon to a fleet of school laptops through Intune and fed it into Wazuh, without writing a single GPO.'
tags = []
+++

## Why I Wanted Sysmon in the First Place

I run IT for a K-12 school. Our fleet is Windows laptops, all enrolled in Intune, and our SIEM is Wazuh. The default Windows event logs give you a decent picture of what's happening, but they miss the good stuff. Process creation with full command lines. Network connections made by a specific executable. Registry run keys getting written. DNS queries from a process nobody expected to make them.

That's what Sysmon gives you. It's a free Sysinternals driver that logs detailed telemetry into the Windows event log, and Wazuh decodes it natively, so the only real work is getting it installed everywhere and telling Wazuh to read it.

## Picking a Config

Sysmon ships with no useful config. You have to bring one, and this is where most people burn time. The old favorite was SwiftOnSecurity's sysmon-config, but it hasn't been updated since mid-2024. I went with Olaf Hartong's sysmon-modular instead. It's maintained, it's mapped to MITRE ATT&CK so you can actually see what behaviors you're covering, and it ships a pre-built "Balanced" profile that covers the common techniques without drowning a laptop in events.

I downloaded the Balanced XML and that became my staff config. For student machines I used the same repo's generator to disable the noisiest event IDs and keep only process creation, network connections, image loads, file creates, and registry run keys. Two configs, same installer.

## The Intune Package

Intune Win32 apps want a folder of files wrapped into an .intunewin package. Mine looked like this:

```
Sysmon-Staff/
├── Sysmon64.exe
├── sysmon-config.xml
├── install.ps1
└── uninstall.ps1
```

The install script is small. If Sysmon is already there, it just reloads the config. If not, it installs the service:

```powershell
$ErrorActionPreference = 'Stop'
$exe = 'C:\Windows\Sysmon64.exe'
$config = Join-Path $PSScriptRoot 'sysmon-config.xml'
$sysmon = Join-Path $PSScriptRoot 'Sysmon64.exe'

if (Test-Path $exe) {
    & $exe -c $config -nologo
} else {
    & $sysmon -accepteula -i $config -nologo
}
exit $LASTEXITCODE
```

Uninstall is one command, `Sysmon64.exe -u force`, wrapped in the same pattern. One thing I added after the fact: the install script also copies the XML to `C:\Windows\Sysmon-config.xml`. That gives Intune a stable detection artifact instead of guessing from the exe alone.

The detection rule I landed on is a PowerShell script, not a file check. It only reports "Installed" when the service is actually running *and* the config file exists:

```powershell
$svc = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -eq 'Running' -and (Test-Path 'C:\Windows\Sysmon-config.xml')) {
    exit 0
}
exit 1
```

Intune re-runs that every 24 hours or so and reinstalls if something breaks. That's the part I like most. I never have to think about whether Sysmon is still on a machine.

## Telling Wazuh to Read It

Sysmon logs into the `Microsoft-Windows-Sysmon/Operational` channel. The Wazuh agent already sat on every laptop, so the agent side was just one `<localfile>` block in the Windows agent group's config on the manager, then a config sync and agent restart. No custom decoders. Wazuh 4.14 parses Sysmon event IDs 1 through 26 out of the box.

One gotcha worth writing down: the agent channel only collects events from the moment it starts. If you add the channel before installing Sysmon, you get silence and no error, which took me a minute to figure out. Install Sysmon first, or in the same assignment wave.

## What It Cost Me in Noise

The Balanced profile is chatty. On the first pilot machine, event ID 11 (file creation) and ID 3 (network connections) dominated ingest by a wide margin. My rule now is a channel like Sysmon should stay under about a third of total agent ingest, and you tune the Sysmon XML, not the agent config, until it gets there. It's easier to trim the config than to wish you had kept an event you threw away at the agent.

## What I'd Tell the Next Person

Three things. Pilot on five machines before you touch the fleet, because your noise profile is not the community's noise profile. Deploy Sysmon before or with the agent channel, not after, since there's no backfill. And pick sysmon-modular over the stale config everyone links to, because the ATT&CK mapping tells you what your blind spots are instead of leaving you to guess.
