---
name: MaxOS release publishing
description: User's standing preference for distributing updater packages and full ISO releases.
---

For MaxOS, publish every update where the updater can download it and include the matching ISO in the GitHub Releases flow. If GitHub cannot host the full ISO as one asset, the user permits moonbat.ddns.net as the ISO host. The user prefers one complete ISO download, not part links.

**Why:** The user asked for all future updates and ISOs to be available through the updater and GitHub releases, and offered moonbat.ddns.net as the fallback host.

Replit asset cards reject files over 100 MiB, so they cannot deliver multi-gigabyte ISOs. The API preview can serve one complete ISO with byte-range resume, but its preview URL is not a durable public release host.

**Why:** A 3 GB ISO exceeded the asset-card upload limit; the user still requires a single complete file without paid storage or split parts.

**How to apply:** Keep updater packages and checksums available through the stable GitHub release feed. For temporary VM testing, verify the single-file route with HEAD, a 206 range, and a resumed full-file checksum. For durable ISO distribution, use GitHub when the asset limit allows it or securely upload to moonbat.ddns.net after the user supplies the SSH account and public path. Do not use paid storage or split the ISO unless the user changes this preference.

When creating commits through GitHub's Git Trees API, preserve each existing file mode; executable build scripts must remain `100755`.

**Why:** Replacing tree entries as `100644` made the release workflow fail with exit code 126 when it tried to execute the package builder.

**How to apply:** Before committing a generated tree, read the base tree modes and carry them forward for every changed path. Only change a mode when the file's intended executability changes.
