#!/usr/bin/env bash
# =============================================================================
# BaconOS Plymouth Splash Theme Installer
# Installs the "baconos" boot splash theme
# =============================================================================

set -euo pipefail

THEME_NAME="baconos"
PLYMOUTH_DIR="/usr/share/plymouth/themes/$THEME_NAME"

log() { echo "🥓 [PLYMOUTH] $*"; }

mkdir -p "$PLYMOUTH_DIR"

# ── Theme descriptor ───────────────────────────────────────────────────────────
cat > "$PLYMOUTH_DIR/$THEME_NAME.plymouth" <<EOF
[Plymouth Theme]
Name=BaconOS
Description=BaconOS boot splash - Dark theme with amber accent
ModuleName=two-step

[two-step]
ImageDir=/usr/share/plymouth/themes/$THEME_NAME
HideDelay=0
TransitionDuration=0.5
EOF

# ── Generate the spinner images using ImageMagick ─────────────────────────────
if command -v convert &>/dev/null; then
    log "Generating spinner frames with ImageMagick..."

    # Background
    convert -size 1920x1080 \
        -define gradient:angle=135 \
        gradient:"#0d0805-#1a1008" \
        "$PLYMOUTH_DIR/background.png"

    # Logo text
    convert -size 400x120 xc:transparent \
        -font "DejaVu-Sans-Bold" \
        -pointsize 72 \
        -fill "#ff8c00" \
        -gravity Center \
        -annotate 0 "BaconOS" \
        "$PLYMOUTH_DIR/logo.png" 2>/dev/null || \
    convert -size 400x120 xc:transparent \
        -pointsize 64 \
        -fill "#ff8c00" \
        -gravity Center \
        -annotate 0 "BaconOS" \
        "$PLYMOUTH_DIR/logo.png"

    # Progress bullet (small amber dot)
    convert -size 16x16 \
        radial-gradient:"#ff8c00-#7a4400" \
        -alpha set \
        \( +clone -threshold 50% \) \
        -compose copy_opacity \
        -composite \
        "$PLYMOUTH_DIR/bullet.png"

    # Entry bullet (for password prompt)
    cp "$PLYMOUTH_DIR/bullet.png" "$PLYMOUTH_DIR/entry.png"

    log "Spinner frames generated ✅"
else
    log "ImageMagick not found — using fallback (text-only) theme"
    cat > "$PLYMOUTH_DIR/$THEME_NAME.plymouth" <<EOF
[Plymouth Theme]
Name=BaconOS
Description=BaconOS boot splash
ModuleName=text

[text]
Title=BaconOS
SubTitle=Stay crispy...
EOF
fi

# ── Script for two-step animation ─────────────────────────────────────────────
cat > "$PLYMOUTH_DIR/$THEME_NAME.script" <<'EOF'
# BaconOS Plymouth Script

Window.SetBackgroundTopColor(0.05, 0.03, 0.02);
Window.SetBackgroundBottomColor(0.10, 0.06, 0.03);

logo_image = Image("logo.png");
logo_sprite = Sprite(logo_image);
logo_sprite.SetX(Window.GetWidth()  / 2 - logo_image.GetWidth()  / 2);
logo_sprite.SetY(Window.GetHeight() / 2 - logo_image.GetHeight() / 2 - 40);
logo_sprite.SetZ(10);

# Progress bar
bar_bg_image   = Image.Scale(Image.NewFromFile("background.png"), Window.GetWidth(), 4);
bar_fg_image   = Image.Scale(Image.NewFromFile("background.png"), 1, 4);

bar_bg = Sprite(bar_bg_image);
bar_bg.SetX(0);
bar_bg.SetY(Window.GetHeight() - 50);
bar_bg.SetZ(10);

bar_fg = Sprite();
bar_fg.SetX(0);
bar_fg.SetY(Window.GetHeight() - 50);
bar_fg.SetZ(11);

fun refresh_callback() {
    ratio = Plymouth.GetBootProgress();
    bar_w = Math.Int(Window.GetWidth() * ratio);
    new_image = Image.Scale(
        Image.NewFromColor(bar_w, 4, 1.0, 0.549, 0.0, 1.0),
        bar_w, 4
    );
    bar_fg.SetImage(new_image);
}

Plymouth.SetRefreshFunction(refresh_callback);
EOF

# ── Activate the theme ─────────────────────────────────────────────────────────
update-alternatives --install /usr/share/plymouth/themes/default.plymouth \
    default.plymouth "$PLYMOUTH_DIR/$THEME_NAME.plymouth" 100 2>/dev/null || true

plymouth-set-default-theme --rebuild-initrd "$THEME_NAME" 2>/dev/null || \
    update-initramfs -u 2>/dev/null || true

log "Plymouth theme '$THEME_NAME' activated ✅"
