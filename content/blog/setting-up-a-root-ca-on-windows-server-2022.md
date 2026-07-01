+++
title = 'Setting Up a Root CA on Windows Server 2022'
date = '2026-06-30T19:00:00-05:00'
summary = ''
tags = []
+++
## Introduction

For this project, I started building a basic internal Public Key Infrastructure using Windows Server 2022. The goal was to create a Root Certificate Authority first, then later build an Issuing CA that would handle certificate requests for the domain.

This is useful in a lab or internal network when you want to issue trusted certificates for things like servers, web portals, remote access, device authentication, or internal services.

For this setup, I used two Windows Server 2022 virtual machines:

* `ROOT-CA`
* `ISSUING-CA`

One thing I found helpful early on was naming the servers clearly. Calling the Root CA `ROOT-CA` and the Issuing CA `ISSUING-CA` makes the environment much easier to understand later, especially when you are looking at certificate paths, templates, or logs.

## Main Explanation

Before installing the Certificate Authority role, I installed Windows Server 2022 on both virtual machines and joined both servers to my Windows Active Directory domain.

For a lab environment, this makes the setup easier because the servers can use domain credentials and integrate directly with Active Directory. In a production PKI design, an offline Root CA is usually kept off the domain and powered off when it is not being used. For this project, I was focused on learning and building a working internal PKI.

The first server I configured was the Root CA.

On the `ROOT-CA` server, I opened **Server Manager** and went to:

**Manage → Add Roles and Features**

From there, I clicked through the wizard until I reached the **Server Roles** section. In the list of roles, I selected:

**Active Directory Certificate Services**

This is the Windows Server role that provides Certificate Authority services.

After selecting the role, I continued through the wizard until I reached the **Role Services** section. For this part, I selected:

**Certification Authority**

This is the core service needed to issue and manage certificates.

After that, I clicked through the rest of the wizard and installed the role.

Once the installation finished, Server Manager showed a warning flag in the top-right corner. This warning appears because the AD CS role is installed, but it still needs to be configured.

I clicked the flag and selected the option to configure Active Directory Certificate Services.

For the credentials, I used a domain admin account. Since this was being configured as an Enterprise CA in Active Directory, the account needs enough permissions to publish the CA information into the domain.

In the configuration wizard, I selected:

**Certification Authority**

Then I chose:

**Enterprise CA**

An Enterprise CA integrates with Active Directory and can use certificate templates. This is helpful when you want domain computers or users to request certificates automatically or through standard templates.

Next, I selected:

**Root CA**

Since this was the first Certificate Authority in the environment, it needed to be the Root CA. The Root CA sits at the top of the trust chain. Any certificates issued by lower-level CAs are trusted because they chain back to this root certificate.

For the private key option, I selected:

**Create a new private key**

Since this was a new CA setup, there was no existing key to reuse.

For the cryptographic settings, I left the defaults in place. In a real production environment, these settings should be reviewed carefully, but for this lab setup the defaults were fine.

Next, I set the common name for the CA.

I used:

`ROOT-CA`

This name is important because it shows up in the certificate chain. Using a simple and clear name makes troubleshooting and documentation much easier later.

After that, I configured the validity period.

For an offline Root CA, a longer validity period such as 20 years can make sense because the Root CA is not issuing day-to-day certificates. It mainly exists to sign subordinate CA certificates.

For an online Root CA, I would use a shorter validity period, such as 10 years.

For this setup, I used:

`20 years`

After that, I left the remaining settings at their defaults and completed the wizard.

At this point, the Root CA was installed and configured.

## Final Thoughts

This was the first step in building a two-tier Microsoft PKI environment. The Root CA is the trust anchor, so it needs to be planned carefully. Even in a lab, it is worth naming it clearly, documenting the settings, and understanding why each option is selected.

The biggest takeaway from this part of the setup is that the Root CA should not be treated like a normal server. In a production design, it should usually be offline and only brought online when needed to sign or renew the Issuing CA certificate.

The next step is to configure the Issuing CA. That server will be responsible for handling the normal certificate requests in the domain, while the Root CA remains protected as the top-level authority.