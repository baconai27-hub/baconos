#!/usr/bin/env bash
# =============================================================================
# BaconOS Chroot Setup Script
# Runs INSIDE the chroot to configure the system
# =============================================================================

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8
export LC_ALL=C

log()   { echo -e "\033[0;32m🥓 [CHROOT]\033[0m $*"; }
error() { echo -e "\033[0;31m❌ [CHROOT ERROR]\033[0m $*" >&2; exit 1; }

# ── APT Sources ───────────────────────────────────────────────────────────────
setup_apt() {
    log "Configuring APT sources..."
    cat > /etc/apt/sources.list <<EOF
# BaconOS — Based on Ubuntu ${UBUNTU_RELEASE:-noble}
deb ${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu} ${UBUNTU_RELEASE:-noble} main restricted universe multiverse
deb ${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu} ${UBUNTU_RELEASE:-noble}-updates main restricted universe multiverse
deb ${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu} ${UBUNTU_RELEASE:-noble}-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu ${UBUNTU_RELEASE:-noble}-security main restricted universe multiverse
EOF

    apt-get update -q
    apt-get upgrade -yq
    log "APT configured ✅"
}

# ── Core packages ─────────────────────────────────────────────────────────────
install_base() {
    log "Installing base system packages..."
    apt-get install -yq --no-install-recommends \
        systemd \
        systemd-sysv \
        dbus \
        dbus-x11 \
        udev \
        util-linux \
        procps \
        coreutils \
        bash \
        zsh \
        wget \
        curl \
        ca-certificates \
        gnupg \
        apt-utils \
        apt-transport-https \
        software-properties-common \
        locales \
        tzdata \
        network-manager \
        NetworkManager \
        openssh-client \
        sudo \
        less \
        man-db \
        nano \
        vim \
        git \
        unzip \
        zip \
        tar \
        xz-utils \
        rsync \
        lsb-release \
        pciutils \
        usbutils \
        acpi \
        acpid \
        laptop-detect \
        dmidecode
    log "Base packages installed ✅"
}

# ── Linux kernel ──────────────────────────────────────────────────────────────
install_kernel() {
    log "Installing Linux kernel..."
    apt-get install -yq \
        linux-image-generic \
        linux-headers-generic \
        linux-firmware \
        initramfs-tools \
        casper \
        lupin-casper
    log "Kernel installed ✅"
}

# ── Desktop environment ───────────────────────────────────────────────────────
install_desktop() {
    log "Installing GNOME desktop environment..."
    apt-get install -yq \
        gnome-shell \
        gnome-session \
        gnome-control-center \
        gnome-settings-daemon \
        gnome-tweaks \
        gnome-shell-extensions \
        gnome-terminal \
        gnome-text-editor \
        gnome-calculator \
        gnome-calendar \
        gnome-clocks \
        gnome-disk-utility \
        gnome-font-viewer \
        gnome-keyring \
        gnome-logs \
        gnome-screenshot \
        gnome-system-monitor \
        gdm3 \
        mutter \
        nautilus \
        eog \
        evince \
        file-roller \
        gedit \
        baobab \
        cheese \
        totem \
        rhythmbox \
        xdg-utils \
        xdg-user-dirs \
        xdg-user-dirs-gtk \
        desktop-file-utils \
        gvfs \
        gvfs-backends \
        network-manager-gnome \
        pulseaudio \
        pavucontrol \
        pipewire \
        pipewire-audio \
        wireplumber
    log "Desktop environment installed ✅"
}

# ── Drivers & Hardware ────────────────────────────────────────────────────────
install_drivers() {
    log "Installing hardware support..."
    apt-get install -yq \
        mesa-vulkan-drivers \
        mesa-va-drivers \
        intel-microcode \
        amd64-microcode \
        firmware-linux \
        firmware-linux-nonfree \
        linux-firmware \
        alsa-base \
        alsa-utils \
        bluez \
        bluetooth \
        blueman \
        cups \
        cups-browsed \
        printer-driver-all \
        sane \
        simple-scan \
        thermald \
        tlp \
        powertop \
        fwupd || true   # some may not exist — soft fail
    log "Hardware support installed ✅"
}

# ── Developer tools ───────────────────────────────────────────────────────────
install_devtools() {
    log "Installing developer tools..."
    apt-get install -yq \
        build-essential \
        gcc \
        g++ \
        make \
        cmake \
        ninja-build \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        nodejs \
        npm \
        default-jdk \
        golang-go \
        rustc \
        cargo \
        ruby \
        perl \
        gdb \
        valgrind \
        strace \
        ltrace \
        lsof \
        htop \
        btop \
        neofetch \
        tree \
        jq \
        bat \
        ripgrep \
        fd-find \
        fzf \
        tmux \
        screen \
        tig \
        docker.io \
        docker-compose || true
    log "Developer tools installed ✅"
}

# ── BaconOS apps ─────────────────────────────────────────────────────────────
install_apps() {
    log "Installing BaconOS curated apps..."
    apt-get install -yq \
        firefox \
        libreoffice \
        libreoffice-gtk3 \
        vlc \
        obs-studio \
        gimp \
        inkscape \
        kdenlive \
        audacity \
        transmission-gtk \
        gparted \
        timeshift \
        flatpak \
        gnome-software-plugin-flatpak || true

    # Add Flathub
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    log "Apps installed ✅"
}

# ── Kitty terminal ────────────────────────────────────────────────────────────
install_kitty() {
    log "Installing Kitty terminal emulator..."
    apt-get install -yq kitty || \
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n 2>/dev/null || true
    log "Kitty installed ✅"
}

# ── Zsh + Oh My Zsh skeleton ──────────────────────────────────────────────────
setup_zsh() {
    log "Configuring Zsh + Oh My Zsh for default user skeleton..."
    apt-get install -yq zsh zsh-autosuggestions zsh-syntax-highlighting

    # Install Oh My Zsh to skel (non-interactive)
    export HOME=/root
    export RUNZSH=no
    export CHSH=no
    export KEEP_ZSHRC=yes
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true

    mkdir -p /etc/skel/.oh-my-zsh
    [[ -d /root/.oh-my-zsh ]] && cp -r /root/.oh-my-zsh/. /etc/skel/.oh-my-zsh/ || true

    # Write custom .zshrc for new users
    cat > /etc/skel/.zshrc <<'ZSHRC'
# BaconOS Default .zshrc — Powered by Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(
    git
    z
    sudo
    history
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    python
    npm
)
source $ZSH/oh-my-zsh.sh 2>/dev/null || true

# BaconOS extras
export EDITOR="nano"
export VISUAL="nano"
export PATH="$HOME/.local/bin:$PATH"

alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tulanp'
alias myip='curl ifconfig.me'
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'
alias bacon='echo "🥓 BaconOS is sizzling!"'
alias neofetch='neofetch'

# Welcome message
echo "🥓 Welcome to BaconOS — Stay crispy, stay curious."
ZSHRC

    log "Zsh setup complete ✅"
}

# ── BaconOS Branding ──────────────────────────────────────────────────────────
apply_branding() {
    log "Applying BaconOS branding..."

    # OS Release
    cat > /etc/os-release <<EOF
NAME="BaconOS"
VERSION="${BACONOS_VERSION:-1.0} (${BACONOS_CODENAME:-Sizzle})"
ID=baconos
ID_LIKE=ubuntu
PRETTY_NAME="BaconOS ${BACONOS_VERSION:-1.0} ${BACONOS_CODENAME:-Sizzle}"
VERSION_ID="${BACONOS_VERSION:-1.0}"
HOME_URL="https://baconos.github.io"
SUPPORT_URL="https://github.com/baconos/baconos/issues"
BUG_REPORT_URL="https://github.com/baconos/baconos/issues"
LOGO="baconos-logo"
EOF

    # lsb_release
    cat > /etc/lsb-release <<EOF
DISTRIB_ID=BaconOS
DISTRIB_RELEASE=${BACONOS_VERSION:-1.0}
DISTRIB_CODENAME=${BACONOS_CODENAME:-Sizzle}
DISTRIB_DESCRIPTION="BaconOS ${BACONOS_VERSION:-1.0} (${BACONOS_CODENAME:-Sizzle})"
EOF

    # Hostname
    echo "baconos" > /etc/hostname

    cat > /etc/hosts <<EOF
127.0.0.1   localhost
127.0.1.1   baconos
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # Issue / MOTD
    cat > /etc/issue <<EOF
BaconOS ${BACONOS_VERSION:-1.0} "${BACONOS_CODENAME:-Sizzle}" \n \l
EOF

    cat > /etc/motd <<'EOF'

  🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓
       Welcome to BaconOS — Stay Crispy!
       Based on Ubuntu — Built for Power Users
  🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓🥓

EOF

    log "Branding applied ✅"
}

# ── GDM / auto-login ──────────────────────────────────────────────────────────
configure_gdm() {
    log "Configuring GDM for live session..."
    mkdir -p /etc/gdm3
    cat > /etc/gdm3/custom.conf <<EOF
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=bacon
TimedLoginEnable=true
TimedLogin=bacon
TimedLoginDelay=10

[security]
[xdmcp]
[chooser]
[debug]
EOF
    log "GDM configured ✅"
}

# ── systemd locale & timezone ─────────────────────────────────────────────────
configure_locale() {
    log "Configuring locale and timezone..."
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata
    log "Locale configured ✅"
}

# ── Enable services ───────────────────────────────────────────────────────────
enable_services() {
    log "Enabling system services..."
    systemctl enable NetworkManager 2>/dev/null || true
    systemctl enable bluetooth     2>/dev/null || true
    systemctl enable cups          2>/dev/null || true
    systemctl enable fwupd         2>/dev/null || true
    systemctl enable gdm3          2>/dev/null || true
    systemctl enable acpid         2>/dev/null || true
    log "Services enabled ✅"
}

# ── Cleanup ────────────────────────────────────────────────────────────────────
cleanup() {
    log "Cleaning up APT caches..."
    apt-get autoremove -yq
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    rm -rf /tmp/* /var/tmp/*
    rm -f /etc/machine-id
    dbus-uuidgen > /etc/machine-id
    truncate -s 0 /etc/machine-id 2>/dev/null || true
    log "Cleanup complete ✅"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    log "Starting BaconOS chroot configuration..."
    setup_apt
    install_base
    install_kernel
    install_desktop
    install_drivers
    install_devtools
    install_apps
    install_kitty
    setup_zsh
    apply_branding
    configure_gdm
    configure_locale
    enable_services
    cleanup
    log "🥓 Chroot configuration complete!"
}

main "$@"
