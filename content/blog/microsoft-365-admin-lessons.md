+++
title = "Microsoft 365 Admin Lessons Learned"
date = 2026-06-12
summary = "What I wish someone had told me before I started administering Microsoft 365 for a K-12 school."
tags = ["microsoft-365", "intune", "entra", "k12"]
+++

Administering Microsoft 365 for a K‑12 school is a different animal than running it for a corporation. You have a mix of staff, students, shared devices, and a user base that ranges from tech-savvy to "what is a password." Here are the lessons I learned the hard way.

## Lesson 1: Groups Are Your Friend

Do not assign licenses or permissions to individual users. Use groups — security groups, mail-enabled security groups, or Microsoft 365 groups — for everything. When someone leaves or changes role, you update the group, not fifteen individual settings.

## Lesson 2: Intune Is Not Optional for K‑12

With shared devices and student accounts, Intune is how you keep things sane. Start with:

- **Enrollment policies** — auto-enroll devices so they are managed from day one
- **Conditional Access** — block legacy auth, require MFA for staff
- **Compliance policies** — mark devices compliant/non-compliant and act on it
- **Configuration profiles** — standardize settings across device fleet

Deploy in audit mode first. Block when you are confident.

## Lesson 3: Naming Conventions Save Sanity

School IT involves a lot of accounts. Use a consistent convention:
- Students: `firstname.lastname.gradYear@domain`
- Staff: `firstinitiallastname@domain`
- Devices: `BUILDING-ROOM-DEVICE##`

It feels tedious up front. It saves hours later.

## Lesson 4: Test in a Pilot Group

Never roll a policy to "All Users." Create a pilot group with 2–3 devices, deploy there, confirm it works, then expand. A bad policy pushed to everyone is an all-hands fire.

## Lesson 5: Document the Tenant

Microsoft 365 has many moving parts — Exchange, Teams, SharePoint, Intune, Entra. Write down what is configured, where, and why. Future-you will be grateful when you are trying to figure out why a conditional access policy exists six months after you created it.

These five habits cover ninety percent of the M365 admin work in a K‑12 environment. The other ten percent is putting out fires — but good habits mean fewer fires.
