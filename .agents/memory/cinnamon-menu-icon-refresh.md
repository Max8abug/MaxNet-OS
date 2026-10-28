---
name: Cinnamon Start icon refresh
description: Refreshing the Cinnamon menu applet after MaxOS changes the synced Start icon or label.
---

Cinnamon's menu applet reads `org.cinnamon`'s global app-menu icon and label when it initializes, but does not subscribe to changes to those global settings. Updating the GSettings values after the panel has loaded can leave the old Mint branding visible until the Cinnamon shell refreshes.

**Why:** MaxOS downloads the configured MaxNet logo during desktop startup, after the Cinnamon panel applet has already initialized.

**How to apply:** Compare the current icon and label with the synced values, update only changed values, then refresh Cinnamon once. Do not restart the shell on every login; that can create a repeated startup cycle.
