BaconOS/
├── .github/
│   └── workflows/
│       └── build-iso.yml              ← CI: shellcheck → yamllint → build → GitHub Release
│
├── branding/
│   ├── ascii-logo.txt                 ← ASCII art logo for terminal / neofetch
│   ├── wallpaper-dark.png             ← AI-generated default desktop wallpaper
│   └── grub-theme/
│       └── theme.txt                  ← GRUB bootloader theme (amber countdown bar)
│
├── build/
│   ├── build.sh                       ← 🔨 Main 5-stage build orchestrator (run as root)
│   ├── chroot-setup.sh                ← Runs inside chroot: installs 100+ pkgs + branding
│   └── cleanup.sh                     ← Unmount bind mounts, optionally wipe workspace
│
├── config/
│   ├── autoinstall/
│   │   ├── user-data                  ← cloud-init subiquity autoinstall YAML
│   │   └── meta-data                  ← (required empty file for nocloud datasource)
│   └── packages/
│       ├── core.list                  ← Always-installed packages
│       ├── devtools.list              ← Developer toolchain
│       └── multimedia.list            ← Audio/video/image apps
│
├── overlay/                           ← Merged into / of the live squashfs filesystem
│   ├── etc/
│   │   ├── apt/apt.conf.d/
│   │   │   └── 99-baconos             ← APT: parallel DL, lean installs, colored output
│   │   ├── dconf/
│   │   │   ├── profile/user           ← dconf DB lookup order
│   │   │   └── db/baconos.d/
│   │   │       └── 00-defaults        ← System-wide GNOME dconf defaults
│   │   ├── default/
│   │   │   └── grub                   ← GRUB options: BaconOS theme, quiet splash
│   │   ├── logrotate.d/
│   │   │   └── baconos                ← Log rotation for firstboot + sudo logs
│   │   ├── neofetch/ascii/
│   │   │   └── BaconOS                ← Custom neofetch ASCII art (3-color)
│   │   ├── NetworkManager/
│   │   │   └── NetworkManager.conf    ← MAC randomization, systemd-resolved, IPv6 privacy
│   │   ├── profile.d/
│   │   │   └── baconos.sh             ← Login shell env + PATH + Wayland vars + random tip
│   │   ├── skel/.config/
│   │   │   ├── kitty/kitty.conf       ← Kitty: amber dark theme, powerline tabs, Nerd Font
│   │   │   └── neofetch/config.conf   ← neofetch layout + BaconOS palette + bar info
│   │   ├── sudoers.d/
│   │   │   ├── baconos                ← bacon user sudo + passwordless CLI helpers
│   │   │   └── baconos-lecture        ← First-time sudo welcome message
│   │   ├── sysctl.d/
│   │   │   └── 99-baconos.conf        ← Kernel tuning: BBR, ZRAM swap, inotify, security
│   │   ├── systemd/system/
│   │   │   ├── baconos-firstboot.service  ← One-shot first-boot wizard (ConditionPath)
│   │   │   └── baconos-zram.service       ← ZRAM compressed swap at boot
│   │   ├── udev/rules.d/
│   │   │   └── 99-baconos.rules       ← I/O scheduler, controllers, ADB, Yubikey, backlight
│   │   └── xdg/autostart/
│   │       └── baconos-welcome.desktop← Autostart welcome app after 5s delay
│   └── usr/
│       ├── bin/
│       │   ├── bacon                  ← 🥓 BaconOS CLI (update/install/remove/search/info/doctor/sizzle)
│       │   └── baconos-welcome        ← GTK4/Libadwaita first-boot welcome app (Python)
│       └── lib/baconos/
│           ├── firstboot.sh           ← First-boot: Nerd Fonts, Papirus, theme, wallpaper, notify
│           ├── install-theme.sh       ← BaconShell GTK3 + GTK4 + GNOME Shell CSS + dconf
│           ├── install-plymouth.sh    ← Plymouth boot splash with amber progress bar
│           └── setup-zram.sh          ← ZRAM device (lz4, 50% RAM, priority 100) + tuning
│
├── output/                            ← (generated) .iso + .md5 + .sha256
├── build_workspace/                   ← (generated) chroot/ + iso/ staging
│
├── .gitignore                         ← Build artifacts, secrets, editor files
├── CHANGELOG.md                       ← Version history (Keep a Changelog format)
├── CONTRIBUTING.md                    ← Contributor guide: setup, standards, PR process
├── Dockerfile                         ← Reproducible build container (Ubuntu 24.04)
├── Makefile                           ← make build/docker-build/lint/validate/qemu/clean
├── README.md                          ← Project overview, features, build instructions
└── STRUCTURE.md                       ← This file
