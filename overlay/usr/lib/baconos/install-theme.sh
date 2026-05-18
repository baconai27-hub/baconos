#!/usr/bin/env bash
# =============================================================================
# BaconOS GNOME Theme Installer
# Installs the BaconShell dark theme with amber/bacon accent colors
# =============================================================================
# Run as: bash /usr/lib/baconos/install-theme.sh [--user bacon]
# =============================================================================

set -euo pipefail

TARGET_USER="${1:-${SUDO_USER:-$USER}}"
TARGET_HOME=$(eval echo "~$TARGET_USER")

log() { echo -e "\033[0;33m🎨 [THEME]\033[0m $*"; }

# ── GTK Theme ─────────────────────────────────────────────────────────────────
install_gtk_theme() {
    log "Installing BaconShell GTK theme..."
    THEME_DIR="$TARGET_HOME/.themes/BaconShell"
    mkdir -p "$THEME_DIR"

    # Use Adwaita-dark as base and override accent colors via GTK settings
    mkdir -p "$THEME_DIR/gtk-3.0"
    mkdir -p "$THEME_DIR/gtk-4.0"

    # GTK 3 override
    cat > "$THEME_DIR/gtk-3.0/gtk.css" <<'EOF'
/* BaconShell GTK3 Theme — Dark with Bacon Amber Accent */
@import url("resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css");

@define-color accent_color #ff8c00;
@define-color accent_bg_color #ff8c00;
@define-color accent_fg_color #1a1008;

/* Window backgrounds */
window, .background { background-color: #1e1e1e; }

/* Header bars */
headerbar {
    background: linear-gradient(to bottom, #2d2d2d, #1e1e1e);
    color: #e8d5b7;
    border-bottom: 1px solid #111;
}

headerbar button.suggested-action {
    background: #ff8c00;
    color: #1a1008;
    border-radius: 6px;
    font-weight: bold;
}

headerbar button.suggested-action:hover {
    background: #ffa833;
}

/* Buttons */
button:checked,
button.toggle:checked {
    background: #ff8c00;
    color: #1a1008;
}

/* Selections */
selection {
    background: alpha(#ff8c00, 0.4);
}

/* Sidebar / lists */
.sidebar {
    background-color: #181818;
}

/* Scrollbars */
scrollbar slider {
    background-color: alpha(#ff8c00, 0.4);
    border-radius: 4px;
    min-width: 6px;
    min-height: 6px;
}

scrollbar slider:hover {
    background-color: #ff8c00;
}

/* Entry fields */
entry {
    border-radius: 6px;
    background-color: #2a2a2a;
    border: 1px solid #444;
    color: #e8d5b7;
}

entry:focus {
    border-color: #ff8c00;
    box-shadow: 0 0 0 2px alpha(#ff8c00, 0.3);
}

/* Switches */
switch:checked {
    background-color: #ff8c00;
}

/* Progress bars */
progressbar progress {
    background-color: #ff8c00;
}

/* Tooltips */
tooltip {
    background-color: #2a2a2a;
    color: #e8d5b7;
    border: 1px solid #ff8c00;
    border-radius: 4px;
}
EOF

    # GTK 4 override
    cat > "$THEME_DIR/gtk-4.0/gtk.css" <<'EOF'
/* BaconShell GTK4 Theme */
@define-color accent_color #ff8c00;
@define-color accent_bg_color #ff8c00;
@define-color accent_fg_color #1a1008;
@define-color window_bg_color #1e1e1e;
@define-color window_fg_color #e8d5b7;
@define-color view_bg_color #242424;
@define-color view_fg_color #e8d5b7;
@define-color headerbar_bg_color #2d2d2d;
@define-color headerbar_fg_color #e8d5b7;
@define-color sidebar_bg_color #181818;
@define-color card_bg_color #2a2a2a;
@define-color popover_bg_color #2d2d2d;
@define-color dialog_bg_color #2d2d2d;
@define-color shade_color alpha(black, 0.36);
@define-color scrollbar_outline_color alpha(white, 0.1);
EOF

    log "GTK theme installed ✅"
}

# ── GNOME Shell Theme ──────────────────────────────────────────────────────────
install_shell_theme() {
    log "Installing GNOME Shell theme..."
    SHELL_THEME_DIR="$TARGET_HOME/.themes/BaconShell/gnome-shell"
    mkdir -p "$SHELL_THEME_DIR"

    cat > "$SHELL_THEME_DIR/gnome-shell.css" <<'EOF'
/* BaconShell GNOME Shell Theme */

/* Top bar */
#panel {
    background-color: rgba(20, 12, 4, 0.92);
    border-bottom: 1px solid rgba(255, 140, 0, 0.3);
    font-size: 13px;
}

#panel .panel-button {
    color: #e8d5b7;
    padding: 0 8px;
}

#panel .panel-button:hover,
#panel .panel-button:active {
    background: rgba(255, 140, 0, 0.2);
    color: #ff8c00;
}

/* Activities button */
#panel #panelActivities .panel-button-text {
    color: #ff8c00;
    font-weight: bold;
}

/* Overview / dash */
.dash-background {
    background-color: rgba(26, 16, 8, 0.88);
    border: 1px solid rgba(255, 140, 0, 0.2);
    border-radius: 18px;
}

.dash-item-container .overview-icon {
    border-radius: 12px;
}

.dash-item-container .overview-icon:hover {
    background-color: rgba(255, 140, 0, 0.18);
}

.dash-separator {
    background-color: rgba(255, 140, 0, 0.3);
}

/* App grid */
.icon-grid .app-well-icon:hover {
    background-color: rgba(255, 140, 0, 0.15);
}

/* Workspace switcher */
.workspace-dot-container .ws-switcher-indicator:checked {
    background-color: #ff8c00;
    width: 20px;
    border-radius: 4px;
}

/* Notifications */
.notification-banner {
    background-color: rgba(30, 18, 8, 0.95);
    border: 1px solid rgba(255, 140, 0, 0.35);
    border-radius: 12px;
}

.notification-banner .notification-source-icon {
    color: #ff8c00;
}

/* Calendar / clock */
.clock-display .panel-button-text {
    color: #e8d5b7;
}

/* Quick settings */
.quick-settings-grid {
    background-color: rgba(30, 18, 8, 0.95);
    border: 1px solid rgba(255, 140, 0, 0.25);
    border-radius: 16px;
}

/* OSD (volume, brightness) */
.osd-window {
    background-color: rgba(20, 12, 4, 0.88);
    border: 1px solid rgba(255, 140, 0, 0.3);
    border-radius: 12px;
    color: #e8d5b7;
}

#osd-bar {
    background-color: rgba(255, 140, 0, 0.25);
    border-radius: 4px;
}

#osd-bar .barlevel-overdrive,
#osd-bar .barlevel {
    background-color: #ff8c00;
    border-radius: 4px;
}

/* App switcher (alt+tab) */
.switcher-list {
    background-color: rgba(26, 16, 8, 0.92);
    border: 1px solid rgba(255, 140, 0, 0.3);
    border-radius: 12px;
}

.switcher-list .item-box:selected {
    background-color: rgba(255, 140, 0, 0.25);
    border-radius: 8px;
}

/* Run dialog */
.run-dialog {
    background-color: rgba(26, 16, 8, 0.95);
    border: 1px solid rgba(255, 140, 0, 0.4);
    border-radius: 12px;
}

.run-dialog > StEntry {
    background-color: rgba(42, 26, 8, 0.9);
    border-radius: 8px;
    color: #e8d5b7;
    caret-color: #ff8c00;
}
EOF

    log "GNOME Shell theme installed ✅"
}

# ── Icon Theme (symlink to Papirus-Dark with amber folder override) ─────────────
install_icons() {
    log "Configuring icon theme..."
    ICONS_DIR="$TARGET_HOME/.local/share/icons"
    mkdir -p "$ICONS_DIR"

    if command -v papirus-folders &>/dev/null; then
        papirus-folders -C yaru --theme Papirus-Dark 2>/dev/null || true
    fi

    log "Icons configured ✅"
}

# ── Apply via dconf (GNOME settings) ─────────────────────────────────────────
apply_gnome_settings() {
    log "Applying GNOME settings..."

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        gtk-theme "BaconShell" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        color-scheme "prefer-dark" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        icon-theme "Papirus-Dark" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        cursor-theme "Yaru" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        font-name "Inter 11" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        monospace-font-name "JetBrains Mono 12" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        document-font-name "Inter 11" 2>/dev/null || true

    # Accent color (GNOME 46+)
    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface \
        accent-color "orange" 2>/dev/null || true

    # Shell theme via User Themes extension
    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.shell.extensions.user-theme \
        name "BaconShell" 2>/dev/null || true

    # Enable important extensions
    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.shell enabled-extensions \
        "['user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com', 'blur-my-shell@aunetx', 'appindicatorsupport@rgcjonas.gmail.com']" \
        2>/dev/null || true

    # Wallpaper (will be set separately by wallpaper script)
    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.background \
        picture-uri "file:///usr/share/backgrounds/baconos/default.jpg" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.background \
        picture-uri-dark "file:///usr/share/backgrounds/baconos/default-dark.jpg" 2>/dev/null || true

    sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.background \
        picture-options "zoom" 2>/dev/null || true

    log "GNOME settings applied ✅"
}

# ── Fix ownership ──────────────────────────────────────────────────────────────
fix_ownership() {
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.themes" 2>/dev/null || true
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local" 2>/dev/null || true
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    log "Installing BaconShell theme for user: $TARGET_USER (home: $TARGET_HOME)"
    install_gtk_theme
    install_shell_theme
    install_icons
    apply_gnome_settings
    fix_ownership
    log "🥓 BaconShell theme installation complete!"
    log "   Log out and back in (or run: killall -3 gnome-shell) to apply changes."
}

main "$@"
