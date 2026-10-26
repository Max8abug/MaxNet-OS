---
name: MaxNet OS offline login
description: Authentication boundary between MaxNet account sync and Linux Mint logins.
---

MaxNet account sign-in is used inside MaxNet OS for account settings sync. Linux Mint login uses the local account password/PIN, which must remain available offline and is not sent to MaxNet. The selected PIN flow uses Mint's standard password management, so the same credential is also used for `sudo`.

**Why:** The user requires MaxNet account sync and an OS-only PIN that can unlock the computer when the MaxNet site is unavailable; they chose the simpler Mint-local password flow.

**How to apply:** Do not make MaxNet connectivity a prerequisite for boot, lock-screen unlock, or local desktop use. Do not sync the local login PIN to the MaxNet account.
