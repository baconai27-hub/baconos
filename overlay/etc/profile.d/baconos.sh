# BaconOS — /etc/profile.d/baconos.sh
# Loaded for all login shells — sets up environment and shows quick tip

# ── BaconOS environment ───────────────────────────────────────────────────────
export BACONOS_VERSION="1.0"
export BACONOS_CODENAME="Sizzle"

# ── Path additions ────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ── Editor defaults ────────────────────────────────────────────────────────────
export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-nano}"
export PAGER="${PAGER:-less}"

# ── Better less ───────────────────────────────────────────────────────────────
export LESS='-R --use-color -Dd+r$Du+b'
export LESSHISTFILE=/dev/null

# ── Coloured GCC output ───────────────────────────────────────────────────────
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ── Go / Rust / Python paths ─────────────────────────────────────────────────
[[ -d "$HOME/go/bin" ]]          && export PATH="$PATH:$HOME/go/bin"
[[ -d "$HOME/.cargo/bin" ]]      && export PATH="$PATH:$HOME/.cargo/bin"
[[ -d "$HOME/.local/lib/python3.12/site-packages" ]] && \
    export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages:${PYTHONPATH:-}"

# ── QT/GTK theming under Wayland ─────────────────────────────────────────────
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland;xcb}"
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export MOZ_ENABLE_WAYLAND=1
export GDK_BACKEND="${GDK_BACKEND:-wayland,x11}"

# ── Only show tip in interactive terminals ────────────────────────────────────
if [[ $- == *i* ]]; then
    # Pick a random quick tip
    _BACON_TIPS=(
        "Run 'bacon update' to keep your system fresh 🥓"
        "Run 'bacon doctor' to check system health 🩺"
        "Run 'bacon sizzle' for a surprise 🎉"
        "Use 'bacon search <pkg>' to find packages 🔍"
        "Flatpak apps: 'flatpak install flathub <app>' 📦"
        "Type 'neofetch' to show system info 🖥️"
        "Kitty terminal: Ctrl+Shift+T for a new tab 🐱"
    )
    _BACON_TIP="${_BACON_TIPS[$RANDOM % ${#_BACON_TIPS[@]}]}"
    echo -e "\033[0;33m💡 Tip:\033[0m ${_BACON_TIP}"
    unset _BACON_TIPS _BACON_TIP
fi
