+++
title = 'How to Deploy AppLocker EXE Rules With Microsoft Intune'
date = '2026-06-30T18:52:32-05:00'
summary = 'A step-by-step guide to deploying AppLocker executable rules through Microsoft Intune using OMA-URI custom configuration profiles.'
tags = []
+++

## Introduction

AppLocker is a Windows application control feature that lets IT admins allow or block apps from running on managed devices. It is useful when you want to stop students or standard users from running unknown or unauthorized `.exe` files while still allowing approved Windows and school applications.

Deploying AppLocker through Microsoft Intune helps manage Windows laptops without touching each device manually. Microsoft's AppLocker CSP supports deploying executable rules through an OMA-URI policy, and the policy value should contain the XML for the matching `RuleCollection` node.

## Steps

1. **Plan what should be allowed or blocked**

   Before creating the policy, decide what users should be able to run.

   Example planning questions:

   - Which apps should students be allowed to open?
   - Which apps should be blocked?
   - Should IT admins be allowed to run everything?
   - Are you only controlling `.exe` files, or will you also need scripts, MSI installers, or Store apps later?

   Important correction: AppLocker is not "deny all" until rules exist in a rule collection. If rules exist for a collection, only files matching allow rules and not matching deny rules can run.

2. **Create the AppLocker policy locally**

   On a test Windows laptop, open **Local Group Policy Editor**.

   Go to:

   ```text
   Computer Configuration
   -> Windows Settings
   -> Security Settings
   -> Application Control Policies
   -> AppLocker
   ```

3. **Create default executable rules**

   Go to **Executable Rules**.

   Right-click and select:

   ```text
   Create Default Rules
   ```

   These default rules are meant to help Windows keep working while you build the policy. They commonly allow users to run apps from `C:\Windows` and `C:\Program Files`, and allow local Administrators to run everything. Microsoft notes that default rules are a starter policy and may need to be modified for stronger security.

4. **Create your custom allow or block rule**

   Right-click **Executable Rules** and select:

   ```text
   Create New Rule
   ```

   Choose whether the rule is an **Allow** or **Deny** rule.

   Then choose the user or group the rule applies to.

   Select one rule condition:

   - **Publisher**
     Uses the app publisher, product name, file name, and version. Best for signed apps.

   - **Path**
     Uses the file or folder path.

   - **File hash**
     Uses the file hash. This is more exact, but may need updating when the app changes.

   Name the rule and create it.

5. **Choose Audit or Enforce mode**

   By default, your policy may be in **Audit only** mode. Audit mode does not actively block the app. It logs what would happen so you can review the results first. Enforce mode actively blocks apps when the rule says they should be blocked.

   To change this:

   ```text
   Right-click AppLocker
   -> Properties
   -> Select the rule collection
   -> Choose Enforce rules
   ```

   For first testing, use **Audit only** before enforcing.

6. **Export the AppLocker policy**

   After the policy is ready:

   ```text
   Right-click AppLocker
   -> Export Policy
   ```

   Save the XML file.

7. **Prepare the XML for Intune**

   Open the exported XML file.

   For an EXE policy, only copy the section that starts with:

   ```xml
   <RuleCollection Type="Exe" EnforcementMode="AuditOnly">
   ```

   or:

   ```xml
   <RuleCollection Type="Exe" EnforcementMode="Enabled">
   ```

   and ends with:

   ```xml
   </RuleCollection>
   ```

   Do **not** copy the full wrapper:

   ```xml
   <AppLockerPolicy Version="1">
   ```

8. **Deploy the policy through Intune**

   In the Intune admin center, create a new configuration profile.

   Use:

   ```text
   Platform: Windows 10 and later
   Profile type: Templates
   Template name: Custom
   ```

   Give the profile a clear name, such as:

   ```text
   WIN11 - AppLocker - EXE Policy - Students
   ```

   Add a custom OMA-URI setting.

   Use:

   ```text
   Name: AppLocker EXE Policy
   OMA-URI: ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/apps/EXE/Policy
   Data type: String
   Value: Paste only the RuleCollection XML
   ```

   In this OMA-URI, `apps` is the grouping name. Microsoft documents the format as:

   ```text
   ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/{Grouping}/EXE/Policy
   ```

9. **Assign the policy to the correct laptop group**

   Assign the Intune policy to the Windows laptop group that should receive it.

   Start with a small pilot group first. Do not deploy directly to all student laptops until the policy has been tested.

10. **Test and review results**

    On a pilot device, sync Intune and test the apps.

    Check whether:

    - Approved apps still open
    - Blocked apps are stopped
    - Admin accounts can still perform support tasks
    - Windows apps like Settings, Start Menu, and required system tools still work

    If using Audit mode, review AppLocker events before switching to Enforce mode.

11. **Roll out to more devices**

    After testing, expand the assignment to more laptops.

    A safe rollout path is:

    ```text
    Test device
    -> Small pilot group
    -> One student group
    -> All student laptops
    ```

## Real-World Example

> A school may use AppLocker to allow Microsoft Office, browsers, and approved learning apps while blocking unknown `.exe` files from running on student laptops.

## Conclusion

AppLocker with Intune is a practical way to control what can run on Windows laptops. Start with default rules, build your allow/block rules carefully, test in Audit mode, and only enforce after confirming that required apps still work.

The best recommendation: always pilot AppLocker on a small group before rolling it out to all devices.