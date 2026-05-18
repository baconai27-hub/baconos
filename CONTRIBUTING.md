# Contributing to BaconOS 🥓

Thanks for wanting to contribute! BaconOS is a community project and welcomes
contributions of all kinds — bug reports, feature requests, documentation,
build improvements, and code.

---

## 📋 Before You Start

1. Read the [README](README.md) and [STRUCTURE](STRUCTURE.md)
2. Search [existing issues](https://github.com/baconos/baconos/issues) before opening a new one
3. For large changes, open an issue first to discuss the approach

---

## 🐛 Reporting Bugs

Please include:
- BaconOS version (`bacon info` or `cat /etc/os-release`)
- Kernel version (`uname -r`)
- Hardware model (`sudo dmidecode -s system-product-name`)
- Steps to reproduce
- Expected vs actual behaviour
- Relevant logs (`journalctl -xe`, `/var/log/baconos-firstboot.log`)

---

## 🔧 Development Setup

```bash
# 1. Fork and clone
git clone https://github.com/YOUR_USERNAME/baconos.git
cd baconos

# 2. Install dependencies (Ubuntu 22.04+ required)
sudo apt install -y shellcheck yamllint

# 3. Run checks before every commit
make check

# 4. Build with Docker (no root needed on your host)
make docker-build
```

---

## 📁 Project Areas

| Area | Files | Notes |
|------|-------|-------|
| **Build system** | `build/*.sh` | Must be POSIX-safe + shellcheck clean |
| **Package lists** | `config/packages/*.list` | One package per line, commented |
| **Theming** | `overlay/usr/lib/baconos/install-theme.sh` | CSS variables only for colors |
| **CLI tool** | `overlay/usr/bin/bacon` | Keep commands intuitive |
| **System config** | `overlay/etc/**` | Justify every change in PR description |
| **CI/CD** | `.github/workflows/` | Must pass on ubuntu-24.04 runners |

---

## ✅ Code Standards

### Shell Scripts

- All scripts **must pass** `shellcheck` — run `make lint`
- Use `set -euo pipefail` at the top
- Use the logging helpers: `log()`, `warn()`, `error()`
- Quote all variable expansions: `"$VAR"` not `$VAR`
- Prefer `[[` over `[` for conditionals

### Package Lists

- One package per line
- Add a comment for non-obvious packages
- Group by function with a `# ── Section ──` header

### Commit Messages

```
type(scope): short description (max 72 chars)

Longer explanation if needed. Wrap at 72 chars.
Fixes #123
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## 🔀 Pull Request Process

1. Branch from `develop` (not `main`)
2. Run `make check` — all checks must pass
3. Test your change in a VM or with Docker
4. Update `CHANGELOG.md` under `[Unreleased]`
5. Open PR against `develop` with a clear description

---

## 🥓 Code of Conduct

Be crispy, not greasy. Be kind, constructive, and collaborative.
Harassment, discrimination, or hostility of any kind is not welcome.

---

*Thanks for helping make BaconOS sizzle! 🥓*
