#!/usr/bin/env bash
# =============================================================================
# BaconOS Post-build Cleanup Script
# Run after build to free up build workspace
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build_workspace"
CHROOT_DIR="$BUILD_DIR/chroot"

log()  { echo -e "\033[0;32m🧹 [CLEANUP]\033[0m $*"; }

# Unmount any stuck mounts
for mnt in tmp sys proc dev/pts dev; do
    mountpoint -q "$CHROOT_DIR/$mnt" 2>/dev/null && \
        umount -lf "$CHROOT_DIR/$mnt" && \
        log "Unmounted $mnt" || true
done

if [[ "${1:-}" == "--full" ]]; then
    log "Full cleanup: removing build workspace..."
    rm -rf "$BUILD_DIR"
    log "Build workspace removed ✅"
else
    log "Partial cleanup (pass --full to remove build workspace)"
fi

log "Cleanup done ✅"
