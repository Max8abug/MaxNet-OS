---
name: MaxOS intro-player compatibility
description: Video-player availability in the Mint live image and offline ISO packaging.
---

The Linux Mint live image used for MaxOS includes Celluloid and its `libmpv` runtime, but not the standalone `mpv` command. The offline ISO remaster manually extracts the MaxOS Debian package payload and updates its package records; it does not install Debian dependencies from an apt repository. Keep the intro playable through Celluloid when `mpv` is unavailable, and declare `celluloid | mpv` so the Mint base satisfies the package dependency. Bound the Celluloid fallback to the supplied clip duration so setup continues after playback.

**Why:** The 0.4.9 package added an `mpv` dependency, but the Mint base image lacked the executable. That would make the first-run intro skip in an offline ISO even though the package worked on an online system where apt could install dependencies.

**How to apply:** When changing the intro player or its dependencies, inspect installed packages in the base SquashFS and validate the dependency and player fallback in both the package and remastered ISO.
