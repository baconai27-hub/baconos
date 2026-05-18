# 🥓 BaconOS

> **A crispy, sizzling Ubuntu-based Linux distribution built for performance, beauty, and fun.**

![BaconOS](assets/baconos-banner.png)

---

## What is BaconOS?

BaconOS is a custom Linux distribution based on **Ubuntu 24.04 LTS (Noble Numbat)**. It strips away bloat, layers on a gorgeous custom GNOME desktop experience, and comes pre-configured with tools that developers, gamers, and power users actually want.

Like real bacon — it's rich, bold, and satisfying.

---

## Features

| Feature | Details |
|---|---|
| **Base** | Ubuntu 24.04 LTS (Noble Numbat) |
| **Desktop** | GNOME 46 with BaconShell theme |
| **Init system** | systemd |
| **Package manager** | APT + Flatpak |
| **Kernel** | Linux 6.8 (mainline Ubuntu kernel) |
| **Browser** | Firefox (pre-configured) |
| **Terminal** | Kitty with custom BaconOS config |
| **Shell** | Zsh + Oh My Zsh (pre-installed) |
| **Compositor** | Mutter (Wayland-first) |

---

## Directory Structure

```
BaconOS/
├── build/                  # Build scripts and automation
│   ├── build.sh            # Main build script
│   ├── chroot-setup.sh     # Chroot customization script
│   └── cleanup.sh          # Post-build cleanup
├── config/
│   ├── autoinstall/        # Ubuntu autoinstall (cloud-init) configs
│   ├── packages/           # Package lists
│   └── preseed/            # Legacy preseed configs
├── overlay/                # Filesystem overlay (goes into squashfs)
│   ├── etc/                # Custom /etc configs
│   ├── usr/                # Custom /usr additions
│   └── home/               # Default skel home
├── branding/               # Logos, wallpapers, splash screens
├── assets/                 # Documentation assets
└── README.md
```

---

## Building BaconOS

> **Requirements:** Ubuntu 22.04+ host, `squashfs-tools`, `xorriso`, `debootstrap`, `live-build`

```bash
# 1. Clone the repo
git clone https://github.com/baconos/baconos.git
cd baconos

# 2. Install build dependencies
sudo apt install -y squashfs-tools xorriso debootstrap live-build \
    syslinux syslinux-utils grub-pc-bin grub-efi-amd64-bin mtools

# 3. Run the build
sudo bash build/build.sh

# Output: baconos-1.0-amd64.iso
```

---

## Default Credentials (Live Session)

| Field | Value |
|---|---|
| Username | `bacon` |
| Password | `sizzle` |
| Root password | `crispy` |

---

## License

BaconOS is free and open source software, built on top of Ubuntu which is licensed under various open source licenses. BaconOS-specific configurations and branding are released under the **MIT License**.

---

*BaconOS — Because your OS should be as good as breakfast.*
