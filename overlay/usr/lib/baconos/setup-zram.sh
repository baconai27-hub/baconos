#!/usr/bin/env bash
# =============================================================================
# BaconOS ZRAM Swap Setup
# Creates a ZRAM device for compressed swap — faster and RAM-friendly
# =============================================================================

set -euo pipefail

log()  { echo "🥓 [ZRAM] $*"; }
warn() { echo "⚠️  [ZRAM] $*" >&2; }

# Calculate ZRAM size = 50% of total RAM, capped at 8GB
TOTAL_RAM_KB=$(awk '/MemTotal:/{print $2}' /proc/meminfo)
TOTAL_RAM_MB=$(( TOTAL_RAM_KB / 1024 ))
ZRAM_MB=$(( TOTAL_RAM_MB / 2 ))
[[ $ZRAM_MB -gt 8192 ]] && ZRAM_MB=8192
ZRAM_BYTES=$(( ZRAM_MB * 1024 * 1024 ))

log "Total RAM: ${TOTAL_RAM_MB}MB  →  ZRAM size: ${ZRAM_MB}MB"

# Load zram kernel module
modprobe zram 2>/dev/null || { warn "zram module not available, skipping"; exit 0; }

# Find or create a free zram device
ZRAM_DEV=""
for dev in /sys/block/zram*; do
    [[ -e "$dev/disksize" ]] || continue
    size=$(cat "$dev/disksize")
    if [[ "$size" == "0" ]]; then
        ZRAM_DEV="/dev/$(basename $dev)"
        break
    fi
done

if [[ -z "$ZRAM_DEV" ]]; then
    # Create a new zram device
    DEV_NUM=$(cat /sys/class/zram-control/hot_add 2>/dev/null || echo 0)
    ZRAM_DEV="/dev/zram${DEV_NUM}"
fi

log "Using device: $ZRAM_DEV"

# Set compression algorithm to lz4 for speed
ZRAM_SYS="/sys/block/$(basename $ZRAM_DEV)"
echo lz4 > "$ZRAM_SYS/comp_algorithm" 2>/dev/null || \
    echo lzo > "$ZRAM_SYS/comp_algorithm" 2>/dev/null || true

# Set size
echo "$ZRAM_BYTES" > "$ZRAM_SYS/disksize"

# Format as swap
mkswap -L "BaconOS-ZRAM" "$ZRAM_DEV"

# Enable swap with high priority
swapon --priority 100 "$ZRAM_DEV"

log "ZRAM swap enabled: $ZRAM_DEV (${ZRAM_MB}MB)"

# Tune swappiness for ZRAM
echo 180 > /proc/sys/vm/swappiness 2>/dev/null || true
echo 1   > /proc/sys/vm/watermark_boost_factor 2>/dev/null || true
echo 0   > /proc/sys/vm/watermark_scale_factor 2>/dev/null || true

log "Kernel swap tuning applied ✅"
