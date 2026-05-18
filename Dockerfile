# =============================================================================
# BaconOS — Dockerfile for reproducible ISO build environment
# Provides a clean Ubuntu 24.04 host with all build dependencies
# =============================================================================
# Usage:
#   docker build -t baconos-builder .
#   docker run --privileged -v $(pwd):/work -w /work baconos-builder sudo bash build/build.sh
# =============================================================================

FROM ubuntu:24.04

LABEL maintainer="BaconOS Team <hello@baconos.dev>"
LABEL description="BaconOS ISO build environment"
LABEL version="1.0"

# Suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV TZ=UTC

# ── Install build dependencies ────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core build tools
    debootstrap \
    squashfs-tools \
    xorriso \
    mtools \
    # GRUB for hybrid ISO
    grub-pc-bin \
    grub-efi-amd64-bin \
    grub-efi-amd64-signed \
    shim-signed \
    # Utilities
    wget \
    curl \
    ca-certificates \
    gnupg \
    rsync \
    git \
    unzip \
    zip \
    xz-utils \
    gzip \
    bzip2 \
    # System tools
    systemd \
    dbus \
    # Image manipulation (for Plymouth theme generation)
    imagemagick \
    # Network
    netbase \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# ── Create output directory ────────────────────────────────────────────────────
RUN mkdir -p /work/output

# ── Set work directory ─────────────────────────────────────────────────────────
WORKDIR /work

# ── Entrypoint ────────────────────────────────────────────────────────────────
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "sudo bash build/build.sh && echo '🥓 Build complete!' && ls -lh output/"]
