# =============================================================================
# BaconOS Makefile
# Convenience wrapper around the build system
# =============================================================================

BACONOS_VERSION ?= 1.0
BACONOS_CODENAME ?= Sizzle
ISO_NAME = baconos-$(BACONOS_VERSION)-amd64.iso

.PHONY: help build clean docker-build docker-shell lint validate check

# ── Default target ────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "  🥓 BaconOS Build System"
	@echo ""
	@echo "  Targets:"
	@echo "    make build          Build the BaconOS ISO (requires root on Linux)"
	@echo "    make build-clean    Clean build from scratch"
	@echo "    make docker-build   Build ISO inside Docker container"
	@echo "    make docker-shell   Open a shell in the build container"
	@echo "    make lint           Run shellcheck on all scripts"
	@echo "    make validate       Validate config files"
	@echo "    make check          Run lint + validate"
	@echo "    make clean          Remove build workspace"
	@echo "    make distclean      Remove build workspace AND output ISO"
	@echo "    make qemu           Test ISO in QEMU (requires qemu)"
	@echo ""
	@echo "  Variables:"
	@echo "    BACONOS_VERSION=$(BACONOS_VERSION)"
	@echo "    BACONOS_CODENAME=$(BACONOS_CODENAME)"
	@echo ""

# ── Build ─────────────────────────────────────────────────────────────────────
build:
	@echo "🥓 Starting BaconOS build..."
	sudo BACONOS_VERSION=$(BACONOS_VERSION) BACONOS_CODENAME=$(BACONOS_CODENAME) \
		bash build/build.sh

build-clean:
	@echo "🥓 Clean build..."
	sudo BACONOS_VERSION=$(BACONOS_VERSION) BACONOS_CODENAME=$(BACONOS_CODENAME) \
		bash build/build.sh --clean

# ── Docker ────────────────────────────────────────────────────────────────────
docker-build:
	@echo "🐳 Building BaconOS inside Docker..."
	docker build -t baconos-builder:latest .
	docker run --rm --privileged \
		-v "$(PWD):/work" \
		-e BACONOS_VERSION=$(BACONOS_VERSION) \
		baconos-builder:latest \
		bash -c "sudo bash build/build.sh"

docker-shell:
	@echo "🐳 Opening Docker build shell..."
	docker build -t baconos-builder:latest .
	docker run --rm -it --privileged \
		-v "$(PWD):/work" \
		baconos-builder:latest

# ── Quality checks ────────────────────────────────────────────────────────────
lint:
	@echo "🔍 Running shellcheck..."
	shellcheck build/build.sh
	shellcheck build/chroot-setup.sh
	shellcheck build/cleanup.sh
	shellcheck overlay/usr/bin/bacon
	shellcheck overlay/usr/lib/baconos/firstboot.sh
	shellcheck overlay/usr/lib/baconos/install-theme.sh
	shellcheck overlay/usr/lib/baconos/install-plymouth.sh
	shellcheck overlay/usr/lib/baconos/setup-zram.sh
	@echo "✅ All scripts passed shellcheck"

validate:
	@echo "🔍 Validating config files..."
	@command -v yamllint >/dev/null 2>&1 && \
		yamllint config/autoinstall/user-data && \
		echo "✅ YAML configs valid" || \
		echo "⚠️  yamllint not installed, skipping YAML validation"

check: lint validate

# ── Cleanup ───────────────────────────────────────────────────────────────────
clean:
	@echo "🧹 Cleaning build workspace..."
	sudo bash build/cleanup.sh --full

distclean: clean
	@echo "🧹 Removing output..."
	rm -rf output/

# ── Test ──────────────────────────────────────────────────────────────────────
qemu:
	@ISO="output/$(ISO_NAME)"; \
	[ -f "$$ISO" ] || { echo "❌ ISO not found: $$ISO (run: make build first)"; exit 1; }; \
	echo "🚀 Booting $(ISO_NAME) in QEMU..."; \
	qemu-system-x86_64 \
		-enable-kvm \
		-m 4G \
		-smp 2 \
		-cdrom "output/$(ISO_NAME)" \
		-boot d \
		-vga virtio \
		-display sdl \
		-usb \
		-device usb-tablet \
		-netdev user,id=net0 \
		-device virtio-net-pci,netdev=net0

qemu-no-kvm:
	@ISO="output/$(ISO_NAME)"; \
	[ -f "$$ISO" ] || { echo "❌ ISO not found: $$ISO"; exit 1; }; \
	qemu-system-x86_64 -m 4G -cdrom "output/$(ISO_NAME)" -boot d
