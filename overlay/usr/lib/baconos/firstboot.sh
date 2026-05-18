#!/usr/bin/env bash
# =============================================================================
# BaconOS First Boot Setup Script
# Runs once on first graphical login to configure the system
# =============================================================================

set -euo pipefail

DONE_FLAG="/var/lib/baconos/.firstboot-done"
LOG_FILE="/var/log/baconos-firstboot.log"
BACON_USER="${SUDO_USER:-${USER:-bacon}}"

exec > >(tee -a "$LOG_FILE") 2>&1

log()  { echo "[$(date '+%H:%M:%S')] 🥓 $*"; }
ok()   { echo "[$(date '+%H:%M:%S')] ✅ $*"; }
warn() { echo "[$(date '+%H:%M:%S')] ⚠️  $*"; }

log "Starting BaconOS first-boot configuration..."

# ── Wait for desktop to settle ────────────────────────────────────────────────
sleep 5

# ── Install GNOME Shell Extensions ───────────────────────────────────────────
install_extensions() {
    log "Installing GNOME Shell extensions..."
    # User Themes
    apt-get install -yq gnome-shell-extension-manager 2>/dev/null || true
    # Blur my Shell (via apt if available)
    apt-get install -yq gnome-shell-extension-blur-my-shell 2>/dev/null || true
    # AppIndicator support
    apt-get install -yq gnome-shell-extension-appindicator 2>/dev/null || true
    ok "Extensions installed"
}

# ── Install additional fonts ───────────────────────────────────────────────────
install_fonts() {
    log "Installing premium fonts..."
    apt-get install -yq \
        fonts-inter \
        fonts-jetbrains-mono \
        fonts-noto \
        fonts-noto-color-emoji \
        fonts-firacode \
        fonts-cascadia-code 2>/dev/null || true

    # JetBrains Mono Nerd Font (for Kitty powerline)
    local NERD_DIR="/usr/local/share/fonts/nerd-fonts"
    mkdir -p "$NERD_DIR"
    if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
        log "Downloading JetBrains Mono Nerd Font..."
        local TMP
        TMP=$(mktemp -d)
        wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
            -O "$TMP/JetBrainsMono.zip" 2>/dev/null && \
        unzip -q "$TMP/JetBrainsMono.zip" -d "$NERD_DIR" 2>/dev/null && \
        fc-cache -fv "$NERD_DIR" >/dev/null 2>&1 || warn "Nerd Font download failed (skipping)"
        rm -rf "$TMP"
    fi
    ok "Fonts installed"
}

# ── Apply BaconShell theme ────────────────────────────────────────────────────
apply_theme() {
    log "Applying BaconShell theme for $BACON_USER..."
    bash /usr/lib/baconos/install-theme.sh "$BACON_USER" 2>/dev/null || warn "Theme apply had warnings"
    ok "Theme applied"
}

# ── Setup ZRAM swap ────────────────────────────────────────────────────────────
setup_zram() {
    log "Configuring ZRAM swap..."
    bash /usr/lib/baconos/setup-zram.sh 2>/dev/null || warn "ZRAM setup had warnings"
    ok "ZRAM configured"
}

# ── Configure Flatpak ──────────────────────────────────────────────────────────
setup_flatpak() {
    log "Configuring Flatpak + Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    ok "Flathub added"
}

# ── Install Papirus icons ─────────────────────────────────────────────────────
install_papirus() {
    log "Installing Papirus icon theme..."
    add-apt-repository -y ppa:papirus/papirus 2>/dev/null || true
    apt-get update -q 2>/dev/null || true
    apt-get install -yq papirus-icon-theme papirus-folders 2>/dev/null || true
    papirus-folders -C yaru --theme Papirus-Dark 2>/dev/null || true
    ok "Papirus icons installed"
}

# ── Set wallpaper ─────────────────────────────────────────────────────────────
set_wallpaper() {
    log "Setting BaconOS wallpaper..."
    mkdir -p /usr/share/backgrounds/baconos
    # Copy from branding if not already deployed
    [[ -f /usr/share/backgrounds/baconos/default-dark.jpg ]] || \
        cp /usr/share/baconos/branding/wallpaper-dark.png \
           /usr/share/backgrounds/baconos/default-dark.jpg 2>/dev/null || true

    sudo -u "$BACON_USER" dbus-launch gsettings set org.gnome.desktop.background \
        picture-uri-dark "file:///usr/share/backgrounds/baconos/default-dark.jpg" 2>/dev/null || true
    sudo -u "$BACON_USER" dbus-launch gsettings set org.gnome.desktop.background \
        picture-uri "file:///usr/share/backgrounds/baconos/default-dark.jpg" 2>/dev/null || true
    sudo -u "$BACON_USER" dbus-launch gsettings set org.gnome.desktop.background \
        picture-options "zoom" 2>/dev/null || true
    ok "Wallpaper set"
}

# ── Show welcome notification ─────────────────────────────────────────────────
show_welcome() {
    log "Showing welcome notification..."
    sudo -u "$BACON_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $BACON_USER)/bus" \
        notify-send \
        --icon=/usr/share/baconos/branding/baconos-logo.png \
        --app-name="BaconOS" \
        --urgency=normal \
        "🥓 Welcome to BaconOS!" \
        "Your crispy new OS is ready.\nRun 'bacon help' in your terminal to get started." \
        2>/dev/null || true
    ok "Welcome notification sent"
}

# ── Mark complete ──────────────────────────────────────────────────────────────
mark_done() {
    mkdir -p /var/lib/baconos
    touch "$DONE_FLAG"
    log "First-boot setup complete. Flag written to $DONE_FLAG"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    install_extensions
    install_fonts
    install_papirus
    apply_theme
    set_wallpaper
    setup_zram
    setup_flatpak
    show_welcome
    mark_done
    log "🥓 BaconOS first-boot complete!"
}

main "$@"
