---
name: MaxNet OS theme identity
description: User requirement for how MaxNet site display themes map to the native desktop.
---

Use MaxOS as the public operating-system name and keep its desktop themes aligned with the eight MaxNet site theme IDs and visual identities. If a local user has not chosen an OS theme yet, offer the theme picker at first desktop startup; do not require a MaxNet sign-in for local theme selection. Treat MaxOS as the expanded desktop version of MaxNet, with the website as its web demo: share app identity, themes, account settings, and app names, while adding local OS tools and offline continuity. Preserve Linux Mint package/repository identifiers and required upstream attribution for compatibility.

Native window appearance has two separate layers: GTK CSS styles client-decorated titlebars and content, while Cinnamon/Muffin window borders require a matching Metacity theme installed and explicitly selected. Keep both layers on the same theme ID, make Vista-like surfaces opaque, and preserve/restore the window-manager theme along with GTK and Cinnamon settings.

**Why:** The user wants an OS version of the MaxNet site, wants the website to feel like a web demo of the fuller OS, wants guests to choose a theme before signing in, and selected MaxOS as the public name while retaining internal compatibility identifiers and upstream credits. GTK-only styling also left native borders on the Mint default, while transparent surfaces did not match opaque website windows.

**How to apply:** Reuse the site theme IDs and names for local desktop theming and MaxNet app launch/sync. Keep MaxNet apps grouped under a MaxNet launcher section, distinguish local system tools, use opaque app windows without browser chrome, and keep the site and OS consistent in app names and shared account settings. Apply each ID consistently to GTK, Cinnamon, and Muffin/Metacity; keep offline choices local, make window-theme backup upgrades backward-compatible, use MaxOS on user-facing system screens and ISO labels, and retain upstream package/repository IDs and credits.
