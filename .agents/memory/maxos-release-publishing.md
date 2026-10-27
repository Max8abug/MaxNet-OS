---
name: MaxOS release publishing
description: User's standing preference for distributing updater packages and full ISO releases.
---

For MaxOS, publish every update where the updater can download it and include the matching ISO in the GitHub Releases flow. If GitHub cannot host the full ISO as one asset, the user permits moonbat.ddns.net as the ISO host. The user prefers one complete ISO download, not part links.

**Why:** The user asked for all future updates and ISOs to be available through the updater and GitHub releases, and offered moonbat.ddns.net as the fallback host.

**How to apply:** Keep updater packages and checksums available through the stable GitHub release feed. Provide each full ISO from the release itself when supported; otherwise securely upload it to moonbat.ddns.net and link it from the release. Do not split the ISO unless the user changes this preference.
