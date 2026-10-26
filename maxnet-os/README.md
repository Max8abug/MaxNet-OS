# MaxNet OS

MaxNet OS is an unofficial Linux Mint Cinnamon customization that makes the existing MaxNet site feel like a first-class desktop app. It adds a MaxNet-branded Cinnamon/GTK theme, wallpaper, app-menu launchers for the site and its features, and an isolated Chromium app window that keeps MaxNet sign-in separate from the user's everyday browser profile.

This is a desktop integration layer, not a new Linux kernel or a replacement for Linux Mint. The chat, forums, Network feed, Eaglercraft, account sign-in, and in-app themes continue to use the MaxNet service at `https://moonbat.ddns.net`; internet access and the MaxNet service are required.

## Included launchers

- MaxNet OS home
- Sign in
- Chat
- Forums
- the Network feed
- Eaglercraft
- MaxNet display-theme settings
- Apply or restore the Cinnamon desktop theme

Direct feature launch requires the small MaxNet frontend patch in `patches/maxnet-feature-intents.patch`. Without that patch the app still opens at its home desktop, but feature-specific launchers cannot open their target window directly.

## Build the Linux Mint integration package

On Linux Mint or Debian with `dpkg-deb` installed:

```bash
./maxnet-os/package/build-deb.sh
sudo apt install ./maxnet-os/dist/maxnet-os_0.1.0_all.deb
```

The launcher defaults to the confirmed MaxNet host. Use **MaxNet OS → Configure** (or run `maxnet-os configure`) to change it. A per-user override is stored under `~/.config/maxnet-os/settings.conf`; no account password or session token is stored by this package.

Chromium/Chrome/Brave opens MaxNet in a clean app window with a separate persistent profile. Firefox and the system browser are supported as fallbacks; those may show normal browser controls. Install Chromium for the closest standalone-app experience.

## Enable direct feature shortcuts in MaxNet

In a clean checkout of your MaxNet repository, run:

```bash
maxnet-os-patch-source /path/to/MaxNet
```

The helper checks the patch against Git before changing files. It only edits the local checkout; it does not commit or push. Review the resulting diff, run the MaxNet typecheck/build, and deploy the MaxNet site before relying on direct shortcuts. The patch maps:

| Launcher intent | MaxNet destination |
| --- | --- |
| `signin` | Sign-in dialog |
| `chat` | Chat window |
| `forum` | Forums window |
| `network` | Network feed |
| `network-wiki` | Network wiki |
| `eaglercraft` | Eaglercraft window |
| `theme` | MaxNet display-theme settings |

Theme settings inside MaxNet remain account-synced using MaxNet's own existing preference behavior. The Cinnamon theme is separate and can be restored with:

```bash
maxnet-os --restore-system-theme
```

## Make a bootable Linux Mint remaster

This repository does not include or redistribute a Linux Mint ISO. To make a bootable image:

1. Download the Linux Mint edition/version and verify its published checksum.
2. Use Cubic on a Linux Mint/Ubuntu host to customize the official ISO.
3. In Cubic's terminal, install `zenity`, `python3`, `xdg-utils`, and Chromium if desired; copy and install the built `.deb`.
4. Apply the theme for the live-session user, then finish Cubic's ISO creation.
5. Boot the result in a VM first. Test sign-in, chat, forum, Network, Eaglercraft/WebGL, theme switching, and live-installer behavior before installing it on a physical computer.

Linux Mint and Cinnamon are upstream open-source projects. MaxNet OS is an unofficial derivative and is not endorsed by the Linux Mint project.
