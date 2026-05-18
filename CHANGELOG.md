# 🥓 BaconOS Changelog

All notable changes to BaconOS are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0] — 2025-XX-XX — "Sizzle" 🥓

### 🎉 Initial Release

This is the first official release of BaconOS — a crispy Ubuntu 24.04 LTS-based
Linux distribution built for developers, power users, and anyone who appreciates
a well-crafted desktop experience.

### Added

**Core System**
- Ubuntu 24.04 LTS (Noble Numbat) as the base
- Linux 6.8 mainline kernel with BaconOS sysctl tuning
- ZRAM compressed swap (50% RAM, lz4, priority 100)
- BBR TCP congestion control enabled by default
- Optimized I/O schedulers per storage device type (NVMe/SSD/HDD/eMMC)
- systemd-resolved with split DNS

**Desktop Environment**
- GNOME 46 with BaconShell theme (GTK3 + GTK4 + GNOME Shell CSS)
- Dark amber color scheme (`#ff8c00` accent, `#0d0805` background)
- System-wide dconf defaults for fonts, wallpaper, keybindings
- Papirus-Dark icon theme with amber folder colors
- Yaru cursor theme
- Inter 11 as the UI font, JetBrains Mono 12 as the monospace font
- BaconOS AI-generated wallpaper (dark, neon-amber aesthetic)
- GRUB theme with countdown progress bar

**Applications**
- Firefox (pre-configured)
- LibreOffice
- VLC, Rhythmbox, Totem
- GIMP, Inkscape, Cheese, EOG
- OBS Studio, Audacity, Kdenlive
- Transmission (BitTorrent)
- GParted, Timeshift
- Flatpak + Flathub pre-configured

**Developer Tooling**
- Git, build-essential, GCC/G++, Make, CMake, Ninja
- Python 3, Node.js, Go, Rust, Java (OpenJDK)
- Docker, Docker Compose
- htop, btop, neofetch, tmux, screen
- ripgrep, fd, fzf, bat, jq, tree
- Kitty terminal with custom amber dark theme + powerline tabs
- Zsh + Oh My Zsh (agnoster theme, autosuggestions, syntax highlighting)

**BaconOS Utilities**
- `bacon` CLI — system management tool (update/install/remove/search/info/doctor/sizzle)
- `baconos-welcome` — GTK4/Libadwaita first-boot welcome app
- First-boot service (auto-installs fonts, icons, theme, wallpaper)
- ZRAM setup service
- Plymouth boot splash (dark amber animated progress)

**System Configuration**
- MAC address randomization (privacy, per-SSID stable MACs)
- IPv6 temporary address support
- Custom APT config (parallel downloads, colored output, lean installs)
- Custom sudoers (passwordless `bacon update`, `bacon doctor`, etc.)
- Comprehensive udev rules (gaming controllers, ADB, Yubikey, backlight)
- Custom neofetch ASCII art + BaconOS color palette
- Random tip shown on each terminal login

**Build System**
- `build/build.sh` — 5-stage ISO builder (bootstrap → chroot → overlay → squashfs → xorriso)
- `build/chroot-setup.sh` — full chroot configurator
- `Makefile` — `make build`, `make docker-build`, `make lint`, `make qemu`
- `Dockerfile` — reproducible build container
- GitHub Actions CI — lint → validate → build → GitHub Release

---

## [Unreleased] — Upcoming

### Planned
- [ ] BaconOS installer (custom Calamares-based GUI installer)
- [ ] BaconOS software center integration
- [ ] Custom Firefox BaconOS start page
- [ ] BaconOS GNOME Shell extension (custom top bar widget)
- [ ] ARM64 / Raspberry Pi build support
- [ ] Automated upgrade path (1.0 → 2.0)
- [ ] BaconOS flatpak repository
- [ ] Live USB persistence support

---

*🥓 Keep it crispy.*
