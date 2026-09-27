#!/usr/bin/env bash
# omarchy/apply.sh — apply this repo's settings to an Omarchy (Arch + Hyprland)
# box. See README.md for why this appends to Omarchy's files instead of stowing
# over them, and for what is deliberately left out.
#
# Usage:
#   cd ~/.dotfiles/omarchy && ./apply.sh
#
# Idempotent: each edit lives between >>>/<<< dotfiles/omarchy markers and a
# re-run replaces its own block. Originals are backed up on first touch.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
FILES="$HERE/files"
BACKUP="$HOME/.dotfiles-backup/omarchy-$(date +%Y%m%d-%H%M%S)"

if ! command -v omarchy >/dev/null 2>&1; then
  echo "This is not an Omarchy box (no 'omarchy' command). See linux-bootstrap.sh for Debian/Ubuntu." >&2
  exit 1
fi

backup() { # backup <path>
  local target=$1 rel=${1#"$HOME"/}
  [ -e "$target" ] || return 0
  [ -e "$BACKUP/$rel" ] && return 0
  mkdir -p "$BACKUP/$(dirname "$rel")"
  cp -a "$target" "$BACKUP/$rel"
}

append_block() { # append_block <target> <snippet> [comment-prefix]
  local target=$1 snippet=$2 prefix=${3:-#}
  local begin="$prefix >>> dotfiles/omarchy" end="$prefix <<< dotfiles/omarchy"

  backup "$target"
  mkdir -p "$(dirname "$target")"
  touch "$target"

  if grep -qF "$begin" "$target"; then
    # Drop the previous block, markers included, so a re-run replaces it.
    awk -v b="$begin" -v e="$end" '
      index($0, b) { skip = 1 }
      !skip        { print }
      index($0, e) { skip = 0 }
    ' "$target" >"$target.omarchy-tmp"
    mv "$target.omarchy-tmp" "$target"
  fi

  {
    printf '%s\n' "$begin"
    cat "$snippet"
    printf '%s\n' "$end"
  } >>"$target"
  echo "  block applied: ${target/#$HOME/~}"
}

install_file() { # install_file <source> <target>
  backup "$2"
  mkdir -p "$(dirname "$2")"
  install -m644 "$1" "$2"
  echo "  installed: ${2/#$HOME/~}"
}

echo "==> bash aliases"
append_block "$HOME/.bashrc" "$FILES/bashrc-aliases.sh"

echo "==> tmux"
append_block "$HOME/.config/tmux/tmux.conf" "$FILES/tmux-extra.conf"
tmux ls >/dev/null 2>&1 && tmux source-file "$HOME/.config/tmux/tmux.conf" || true

echo "==> Hyprland"
append_block "$HOME/.config/hypr/bindings.lua" "$FILES/hypr-bindings.lua" "--"
append_block "$HOME/.config/hypr/looknfeel.lua" "$FILES/hypr-looknfeel.lua" "--"
append_block "$HOME/.config/hypr/autostart.lua" "$FILES/hypr-autostart.lua" "--"
append_block "$HOME/.config/hypr/hyprsunset.conf" "$FILES/hyprsunset-evening.conf"

echo "==> neovim (on top of Omarchy's LazyVim)"
NVIM_SRC="$REPO/nvim/.config/nvim"
NVIM_DST="$HOME/.config/nvim"
# See README.md for why colorscheme/lualine/treesitter/notion are not in this list.
for spec in blink-cmp disabled flash lazygit no-neckpain presenting telescope nvim-tmux-navigation; do
  install_file "$NVIM_SRC/lua/plugins/$spec.lua" "$NVIM_DST/lua/plugins/$spec.lua"
done
install_file "$FILES/nvim-zen-mode.lua" "$NVIM_DST/lua/plugins/zen-mode.lua"
install_file "$FILES/nvim-lazyvim.json" "$NVIM_DST/lazyvim.json"
append_block "$NVIM_DST/lua/config/options.lua" "$FILES/nvim-options.lua" "--"
append_block "$NVIM_DST/lua/config/keymaps.lua" "$FILES/nvim-keymaps.lua" "--"

echo "==> web apps"
# Chromium needs the OAuth client flags before it will sign in to a Google account.
omarchy install chromium google account >/dev/null 2>&1 || true
webapp_install() { # webapp_install <name> <url>
  if [ -e "$HOME/.local/share/applications/$1.desktop" ]; then
    echo "  already installed: $1"
  else
    omarchy webapp install "$1" "$2" "" >/dev/null && echo "  installed: $1"
  fi
}
webapp_install "Gmail" "https://mail.google.com/mail/u/0/"
webapp_install "Google Calendar" "https://calendar.google.com/calendar/u/0/r"
webapp_install "Slack" "https://app.slack.com/client"
webapp_install "Notion" "https://www.notion.so/"
webapp_install "Claude" "https://claude.ai/new"

# Omarchy preinstalls that go unused here. Keybindings for them still exist in
# Omarchy's defaults; removing the launcher only clears the app list.
for app in HEY Basecamp X Zoom Discord "Google Photos" "Google Maps" "Google Messages" "Google Contacts" WhatsApp YouTube; do
  if [ -e "$HOME/.local/share/applications/$app.desktop" ]; then
    omarchy webapp remove "$app" >/dev/null 2>&1 && echo "  removed: $app"
  fi
done

echo "==> power profiles"
omarchy powerprofiles set battery power-saver >/dev/null
omarchy powerprofiles set ac balanced >/dev/null
echo "  battery: power-saver, ac: balanced"

echo "==> validating Hyprland config"
if command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; then
  hyprctl reload >/dev/null
  errors=$(hyprctl configerrors 2>&1)
  if [ -n "$errors" ] && [ "$errors" != "no errors" ]; then
    echo "!! hyprctl configerrors:" >&2
    echo "$errors" >&2
  else
    echo "  no config errors"
  fi
else
  echo "  (Hyprland not running — config applies at next login)"
fi

cat <<EOF

==> Done. Backups (first run only): ${BACKUP/#$HOME/~}

Next steps:
  - Open a new terminal for the aliases.
  - Restart Chromium, then sign in to your Google account and each web app.
  - Run nvim once: 'Lazy! install' pulls the new specs, then :Mason and
    :TSUpdate interactively (see the top-level readme's "Known gaps").
  - On the 2013 MacBook Air, also run: hardware/macbook-air-6-1.sh
EOF
