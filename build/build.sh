#!/usr/bin/env bash
# =============================================================================
# BaconOS Build Script
# Builds a custom Ubuntu 24.04-based ISO called BaconOS
# =============================================================================
# Usage: sudo bash build/build.sh [--clean] [--no-cache]
# =============================================================================

# shellcheck disable=SC2034
set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYN='\033[0;36m'
RST='\033[0m'
BOLD='\033[1m'

BACON="🥓"

log()    { echo -e "${GRN}${BACON}  [BUILD]${RST}  $*"; }
warn()   { echo -e "${YLW}⚠️   [WARN]${RST}   $*"; }
error()  { echo -e "${RED}❌  [ERROR]${RST}  $*" >&2; exit 1; }
header() { echo -e "\n${MAG}${BOLD}══════════════════════════════════════════${RST}"; \
           echo -e "${MAG}${BOLD}  $*${RST}"; \
           echo -e "${MAG}${BOLD}══════════════════════════════════════════${RST}\n"; }

# ── Configuration ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build_workspace"
CHROOT_DIR="$BUILD_DIR/chroot"
ISO_DIR="$BUILD_DIR/iso"
OUTPUT_DIR="$PROJECT_ROOT/output"

UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu"
UBUNTU_RELEASE="noble"          # Ubuntu 24.04 LTS
BACONOS_VERSION="1.0"
BACONOS_CODENAME="Sizzle"
ISO_NAME="baconos-${BACONOS_VERSION}-amd64.iso"
ISO_LABEL="BaconOS ${BACONOS_VERSION}"

CLEAN_BUILD=false
# shellcheck disable=SC2034
NO_CACHE=false

# ── Parse args ────────────────────────────────────────────────────────────────
for arg in "$@"; do
    case $arg in
        --clean)    CLEAN_BUILD=true ;;
        --no-cache) NO_CACHE=true ;;
        --help)
            echo "Usage: sudo bash build/build.sh [--clean] [--no-cache]"
            echo "  --clean     Remove existing build workspace before building"
            echo "  --no-cache  Force re-download of all packages"
            exit 0
            ;;
        *) warn "Unknown argument: $arg" ;;
    esac
done

# ── Preflight checks ──────────────────────────────────────────────────────────
check_root() {
    [[ $EUID -eq 0 ]] || error "This script must be run as root (sudo)."
}

check_deps() {
    header "Checking build dependencies"
    local missing=()
    for cmd in debootstrap xorriso mksquashfs grub-mkrescue wget curl; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        else
            log "Found: $cmd"
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}\nRun: sudo apt install -y squashfs-tools xorriso debootstrap grub-pc-bin grub-efi-amd64-bin mtools"
    fi
    log "All dependencies satisfied ✅"
}

# ── Stage 1: Bootstrap ────────────────────────────────────────────────────────
bootstrap_chroot() {
    header "Stage 1 — Bootstrap Ubuntu ${UBUNTU_RELEASE^}"

    if [[ "$CLEAN_BUILD" == true && -d "$CHROOT_DIR" ]]; then
        log "Clean build requested — removing $CHROOT_DIR"
        rm -rf "$CHROOT_DIR"
    fi

    if [[ -d "$CHROOT_DIR/usr" ]]; then
        log "Chroot already exists, skipping debootstrap (use --clean to redo)"
        return
    fi

    mkdir -p "$CHROOT_DIR"
    log "Running debootstrap (this may take a while)..."
    debootstrap \
        --arch=amd64 \
        --variant=minbase \
        --include=systemd,dbus,apt,wget,gnupg \
        "$UBUNTU_RELEASE" \
        "$CHROOT_DIR" \
        "$UBUNTU_MIRROR"

    log "Bootstrap complete ✅"
}

# ── Stage 2: Configure chroot ─────────────────────────────────────────────────
configure_chroot() {
    header "Stage 2 — Configuring BaconOS inside chroot"

    # Mount pseudo-filesystems
    mount --bind /dev     "$CHROOT_DIR/dev"
    mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
    mount -t proc proc    "$CHROOT_DIR/proc"
    mount -t sysfs sysfs  "$CHROOT_DIR/sys"
    mount -t tmpfs tmpfs  "$CHROOT_DIR/tmp"

    # Copy setup script into chroot
    cp "$SCRIPT_DIR/chroot-setup.sh" "$CHROOT_DIR/tmp/chroot-setup.sh"
    chmod +x "$CHROOT_DIR/tmp/chroot-setup.sh"

    # Pass build config as environment
    chroot "$CHROOT_DIR" /usr/bin/env \
        BACONOS_VERSION="$BACONOS_VERSION" \
        BACONOS_CODENAME="$BACONOS_CODENAME" \
        UBUNTU_RELEASE="$UBUNTU_RELEASE" \
        UBUNTU_MIRROR="$UBUNTU_MIRROR" \
        bash /tmp/chroot-setup.sh

    log "Chroot configuration complete ✅"

    # Unmount pseudo-filesystems
    cleanup_mounts
}

cleanup_mounts() {
    for mnt in tmp sys proc dev/pts dev; do
        if mountpoint -q "$CHROOT_DIR/$mnt" 2>/dev/null; then
            umount -lf "$CHROOT_DIR/$mnt" || true
        fi
    done
}

# ── Stage 3: Copy overlay ─────────────────────────────────────────────────────
apply_overlay() {
    header "Stage 3 — Applying BaconOS filesystem overlay"

    if [[ -d "$PROJECT_ROOT/overlay" ]]; then
        log "Copying overlay files..."
        cp -a "$PROJECT_ROOT/overlay/." "$CHROOT_DIR/"
        log "Overlay applied ✅"
    else
        warn "No overlay directory found, skipping"
    fi

    # Set correct permissions on skel
    if [[ -d "$CHROOT_DIR/etc/skel" ]]; then
        chroot "$CHROOT_DIR" bash -c "
            useradd -m -s /bin/zsh -G sudo,audio,video,plugdev,netdev bacon 2>/dev/null || true
            echo 'bacon:sizzle' | chpasswd
            echo 'root:crispy'  | chpasswd
            chown -R bacon:bacon /home/bacon
        "
    fi

    log "Overlay complete ✅"
}

# ── Stage 4: Build squashfs + ISO ─────────────────────────────────────────────
build_iso() {
    header "Stage 4 — Building ISO image"

    mkdir -p "$ISO_DIR"/{casper,boot/grub,EFI/boot}
    mkdir -p "$OUTPUT_DIR"

    # Create squashfs filesystem
    log "Compressing filesystem with squashfs (this will take a while)..."
    mksquashfs \
        "$CHROOT_DIR" \
        "$ISO_DIR/casper/filesystem.squashfs" \
        -comp xz \
        -e boot \
        -noappend \
        -no-progress \
        2>&1 | tail -5

    log "squashfs created ✅"

    # Manifest
    # shellcheck disable=SC2016
    chroot "$CHROOT_DIR" dpkg-query -W --showformat='${Package} ${Version}\n' \
        > "$ISO_DIR/casper/filesystem.manifest"

    # Copy kernel and initrd from chroot
    log "Copying kernel and initrd..."
    KERNEL=$(find "$CHROOT_DIR/boot" -maxdepth 1 -name "vmlinuz-*" 2>/dev/null | sort -V | tail -n 1)
    INITRD=$(find "$CHROOT_DIR/boot" -maxdepth 1 -name "initrd.img-*" 2>/dev/null | sort -V | tail -n 1)

    [[ -z "$KERNEL" ]] && error "No kernel found in chroot"
    [[ -z "$INITRD" ]] && error "No initrd found in chroot"

    cp "$KERNEL" "$ISO_DIR/casper/vmlinuz"
    cp "$INITRD" "$ISO_DIR/casper/initrd"
    log "Kernel: $(basename "$KERNEL")"
    log "Initrd: $(basename "$INITRD")"

    # Write GRUB config
    write_grub_config

    # Build ISO
    log "Building ISO with xorriso..."
    xorriso -as mkisofs \
        -iso-level 3 \
        -volid "$ISO_LABEL" \
        -full-iso9660-filenames \
        -output "$OUTPUT_DIR/$ISO_NAME" \
        --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img 2>/dev/null || true \
        -partition_offset 16 \
        --mbr-force-bootable \
        -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b \
            /usr/lib/grub/x86_64-efi/grub.efi 2>/dev/null || true \
        -appended_part_as_gpt \
        -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 2>/dev/null || true \
        -c '/boot.catalog' \
        -b '/boot/grub/i386-pc/eltorito.img' \
            -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
        -eltorito-alt-boot \
        -e '--interval:appended_partition_2:::' \
            -no-emul-boot \
        "$ISO_DIR" \
        2>&1 | grep -v "^$" | tail -20 || \
    xorriso -as mkisofs \
        -iso-level 3 \
        -volid "$ISO_LABEL" \
        -full-iso9660-filenames \
        -output "$OUTPUT_DIR/$ISO_NAME" \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        "$ISO_DIR"

    local iso_size
    iso_size=$(du -sh "$OUTPUT_DIR/$ISO_NAME" | cut -f1)
    log "ISO built ✅  →  $OUTPUT_DIR/$ISO_NAME  ($iso_size)"
}

write_grub_config() {
    log "Writing GRUB bootloader config..."
    cat > "$ISO_DIR/boot/grub/grub.cfg" <<GRUBEOF
# BaconOS ${BACONOS_VERSION} "${BACONOS_CODENAME}" GRUB Configuration

set default=0
set timeout=10
set timeout_style=menu

# Load graphics
insmod all_video
insmod gfxterm
terminal_output gfxterm

# BaconOS theme colors
set color_normal=white/black
set color_highlight=black/yellow

menuentry "🥓 BaconOS ${BACONOS_VERSION} — Try without installing" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}

menuentry "🥓 BaconOS ${BACONOS_VERSION} — Install BaconOS" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
    initrd /casper/initrd
}

menuentry "BaconOS — Safe graphics mode" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper nomodeset quiet splash ---
    initrd /casper/initrd
}

menuentry "BaconOS — Check disk for defects" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
    initrd /casper/initrd
}

menuentry "Boot from next volume" {
    exit 1
}

menuentry "UEFI Firmware Settings" {
    fwsetup
}
GRUBEOF
}

# ── Stage 5: Finalize ─────────────────────────────────────────────────────────
finalize() {
    header "Stage 5 — Finalizing"

    # Write checksums
    pushd "$OUTPUT_DIR" > /dev/null
    md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
    popd > /dev/null

    echo
    echo -e "${GRN}${BOLD}╔══════════════════════════════════════════╗${RST}"
    echo -e "${GRN}${BOLD}║   🥓  BaconOS build COMPLETE!  🥓         ║${RST}"
    echo -e "${GRN}${BOLD}╚══════════════════════════════════════════╝${RST}"
    echo
    echo -e "  ISO:    ${CYN}$OUTPUT_DIR/$ISO_NAME${RST}"
    echo -e "  MD5:    ${CYN}$OUTPUT_DIR/${ISO_NAME}.md5${RST}"
    echo -e "  SHA256: ${CYN}$OUTPUT_DIR/${ISO_NAME}.sha256${RST}"
    echo
    echo -e "  ${YLW}Test with QEMU:${RST}"
    echo -e "  ${BLU}qemu-system-x86_64 -m 4G -cdrom $OUTPUT_DIR/$ISO_NAME -boot d${RST}"
    echo
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    header "🥓 BaconOS ${BACONOS_VERSION} \"${BACONOS_CODENAME}\" — Build System"
    echo -e "  Base:    Ubuntu ${UBUNTU_RELEASE^} (24.04 LTS)"
    echo -e "  Target:  $ISO_NAME"
    echo -e "  Output:  $OUTPUT_DIR"
    echo

    check_root
    check_deps
    bootstrap_chroot
    configure_chroot
    apply_overlay
    build_iso
    finalize
}

trap 'cleanup_mounts; error "Build interrupted"' INT TERM

main "$@"
