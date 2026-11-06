---
name: Cinnamon Start icon refresh
description: Refreshing the Cinnamon menu applet after MaxOS changes the synced Start icon or label.
---

Cinnamon's menu applet reads `org.cinnamon`'s global app-menu icon and label when it initializes, but does not subscribe to changes to those global settings. Updating the GSettings values after the panel has loaded can leave the old Mint branding visible until the Cinnamon shell refreshes.

The applet may also have a custom icon and label in its per-instance JSON settings. Current Cinnamon stores these under `$XDG_CONFIG_HOME/cinnamon/spices/menu@cinnamon.org/`; older installs may still use `~/.cinnamon/configs/menu@cinnamon.org/` when no current-path file exists. A `menu-custom` value of `true` makes that saved icon override the global GSettings icon.

**Why:** MaxOS downloads the configured MaxNet logo during desktop startup, after the Cinnamon panel applet has already initialized. Existing per-instance customization can take precedence over the global icon, and legacy settings remain active when the current settings file is absent.

**How to apply:** Compare and update both global GSettings and any existing per-instance JSON files in both locations, changing only differing values. Refresh Cinnamon once if anything changed. Do not restart the shell on every login; that can create a repeated startup cycle.
