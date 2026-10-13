+++
title = 'How to Set Up Pi-hole on Debian 13'
date = '2026-10-13T17:55:00-05:00'
summary = 'Network-wide ad blocking with Pi-hole on Debian 13, starting with what DNS actually is and why a DNS server with a blocklist works.'
tags = ['linux', 'networking', 'pi-hole']
+++
## How to Set Up Pi-hole on Debian 13

### Introduction

Every device on your network asks a DNS server for help dozens of times a day, and most people never think about it until it breaks. Pi-hole is a DNS server you run yourself, and once it is in place it quietly blocks ads and trackers for everything on the network. Not just the devices with an ad blocker. The TV, the smart plug, the kid's tablet, all of it.

In this post I will walk through setting up Pi-hole on Debian 13, starting with what DNS actually is. The setup makes a lot more sense once you know what problem it solves.

### What Is DNS, Actually?

DNS is the phonebook of the internet. Computers do not talk to each other by name, they use IP addresses like 142.250.80.14. Nobody wants to memorize those. DNS sits in the middle. When you type google.com into a browser, your device asks a DNS server what the IP address for google.com is, gets an answer, and only then does the actual connection happen.

Two things about this matter for Pi-hole.

First, every device on your network uses DNS constantly. All of it flows through whatever DNS server your network hands out, which is usually the router.

Second, DNS is just a question and answer service. Nothing forces the DNS server to answer honestly. When a page wants to load an ad from doubleclick.net, that has to start with a DNS lookup. If the DNS server decides that domain does not exist, the ad never loads. The page never finds out where the ad lives.

That is the entire trick behind Pi-hole. It is a DNS server with a blocklist. When a device asks for the address of a known tracking or ad domain, Pi-hole returns nothing, and the request dies right there. Because it runs at the network level, everything benefits, including devices that cannot run an ad blocker at all. I have a smart TV that is genuinely unusable without one, and this fixed it without touching the TV.

### What You Need Before You Start

- A Debian 13 machine. A VM, a Raspberry Pi, any always-on box. A VM with 512 MB of RAM is genuinely enough.
- A static IP address for that machine. This is the prerequisite people skip and then regret. Every device on your network will be pointed at this machine for DNS, and if its address changes, DNS breaks for the whole network. Set a static IP in the OS or make a DHCP reservation on the router first.
- sudo access on the machine.
- A tolerance for a few minutes of DNS downtime. Do it outside peak hours and nobody will notice.

### Installing Pi-hole, Step by Step

#### Step 1: Fix the Port 53 Conflict First

Debian runs systemd-resolved by default, and it listens on port 53, the same port Pi-hole needs. Skip this step and the installer fails or runs half-broken, and the error does not point you here. Ask me how I know.

Edit the resolved configuration:

```
sudo nano /etc/systemd-resolved.conf
```

Add or uncomment this line:

```
DNSStubListener=no
```

Then restart the service:

```
sudo systemctl restart systemd-resolved
```

#### Step 2: Run the Installer

Pi-hole ships an official install script:

```
curl -sSL https://install.pi-hole.net | bash
```

Piping scripts straight into bash gives some people pause, which is fair. You can download it, read it, then run it if you prefer. The installer walks you through a series of prompts and the defaults are sensible for a typical home or lab network. Keep the default interface, pick an upstream DNS provider, which is where Pi-hole sends the queries it does not block (Cloudflare and Quad9 are both good), and accept the default blocklists.

Near the end it asks about the web interface. Enable it. You will want the dashboard.

#### Step 3: Set the Admin Password

The installer may or may not generate a random password for the dashboard depending on how the install went. Set it yourself and skip the guessing:

```
pihole -a -p
```

#### Step 4: Verify It Works

From another machine on the same network, point a DNS lookup at the Pi-hole:

```
nslookup pi.hole <pi-hole-ip>
```

An answer back means DNS resolution works. Then open the dashboard at http://<pi-hole-ip>/admin and watch the query log fill up in real time. Every lookup from every device on your network, live. It is oddly interesting for the first ten minutes, and mildly horrifying once you realize how much your phone calls home.

#### Step 5: Point Your Network at Pi-hole

This is the step that actually turns it on. In your router settings, find the DHCP or DNS configuration and set the DNS server to the Pi-hole's IP address.

Do not add your old DNS server as a backup. A secondary DNS server means some devices occasionally bypass Pi-hole, and ads leak through in a way that looks random and maddening instead of broken. One DNS server. The Pi-hole.

Reboot a device or renew its DHCP lease, then load a news site. The whitespace where ads used to be is the finish line.

### A Few Things Worth Knowing

- If the Pi-hole goes down, DNS goes down with it. The internet will feel broken even though the network is fine. This is the trade for a single DNS server, and it is why the static IP and the always-on machine matter.
- You can add local names under Local DNS Records in the dashboard, so nas.home resolves without editing /etc/hosts on every machine you own.
- `pihole -up` updates Pi-hole itself. Keep Debian patched with `apt update && apt upgrade` like anything else.

### Why This Matters

Pi-hole looks like a weekend toy but it teaches something real about how networks work. Once you have run your own DNS server, things like DHCP option 6, upstream resolvers, and DNS filtering stop being abstract. You have watched every query on your own network scroll past in a log.

It is also one of the few homelab projects the whole household notices immediately, even if they have no idea why the TV got tolerable.

### Conclusion

The steps above take a fresh Debian 13 install to network-wide ad blocking in under an hour. Free port 53, run the installer, set the password, point the router at it. The things to carry forward: static IP before you start, one DNS server rather than a fallback, and the reminder that your DNS server is now critical infrastructure, so treat it like it.

If you run a homelab and want to compare notes on DNS, monitoring, or network setup, feel free to reach out.
