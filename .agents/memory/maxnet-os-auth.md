---
name: MaxNet OS offline login
description: Authentication boundary between MaxNet account sync and Linux Mint logins.
---

MaxNet sign-in is optional during first desktop setup and is used only to sync site preferences, rank/permissions, and available apps through a short-lived one-time code; the OS sync helper never receives the MaxNet password or browser session. The browser keeps the site session locally for MaxNet apps. Site roles never grant Linux administrator access. Linux Mint login uses the local account password/PIN, which must remain available offline and is not sent to MaxNet. The selected PIN flow uses Mint's standard password management, so the same credential is also used for `sudo`.

**Why:** The user requires MaxNet account sync and a local PIN/password that can unlock the computer when the MaxNet site is unavailable; they chose the simpler Mint-local password flow.

**How to apply:** Do not make MaxNet connectivity a prerequisite for boot, lock-screen unlock, or local desktop use. Never sync the local login PIN or password, and do not map MaxNet ranks or permissions to Linux privileges.
