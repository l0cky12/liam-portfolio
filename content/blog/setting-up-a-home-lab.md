+++
title = "Setting Up a Home Lab"
date = 2026-06-28
summary = "How I built a home lab for testing, learning, and breaking things without consequences."
tags = ["homelab", "proxmox", "linux", "virtualization"]
+++

Every system administrator needs a place to break things without consequences. For me, that place is my home lab. In this post I walk through the hardware, hypervisor, and network setup I use to test new tools, simulate workflows, and learn skills that transfer directly to my work environment.

## Why Build a Home Lab?

At work I manage production systems. I cannot afford to experiment on them. A home lab gives me:

- A sandbox to test configuration changes before touching production
- A way to reproduce issues in a controlled environment
- Hands-on practice with tools and platforms I want to learn
- A safe place to intentionally break and fix things

## Hardware

My lab started modestly and grew over time. The core components:

- **Mini PC** — repurposed as a Proxmox VE host with 32 GB RAM and a 1 TB NVMe SSD
- **Managed switch** — for VLAN segmentation and traffic monitoring
- **Cable modem + router** — standard consumer gear, nothing fancy

It does not need to be expensive. An old desktop with 16 GB of RAM is more than enough to start. The goal is functionality, not rackmount perfection.

## Hypervisor: Proxmox VE

I chose Proxmox VE as the hypervisor because it maps closest to what I use at work. It runs Debian under the hood, supports both VMs and containers (LXC), and has a solid web interface.

After installing Proxmox on the mini PC, I created VMs and LXCs for:

| VM/LXC | Purpose |
|--------|---------|
| Debian LXC | Ad-blocking DNS (Pi-hole) |
| Debian VM | Ansible control node |
| Debian LXC | File share (Samba) |
| Debian VM | Monitoring stack |

## Network Segmentation

I split the lab into VLANs to mimic a real environment:

- **VLAN 10** — Management (Proxmox, SSH)
- **VLAN 20** — Services (DNS, file share)
- **VLAN 30** — Clients (test workstations)

This forces me to think about firewall rules and routing — the same skills I use at NOMMA.

## Lessons Learned

1. **Document everything.** A lab is practice for documentation. If I cannot explain what I did, I did not understand it.
2. **Back up before you change.** Proxmox snapshots take seconds and save hours.
3. **Start small.** One VM with one service teaches more than ten empty VMs.

A home lab is not about having the best gear — it is about having a place to practice. Start with what you have, break it, fix it, and document what you learned.
