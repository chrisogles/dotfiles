#!/usr/bin/env bash
# ~/dotfiles/linux-bootstrap.sh
#
# One-shot setup for a fresh Debian/Ubuntu box: installs the terminal
# productivity toolchain, stows the relevant dotfiles, and bootstraps
# tmux/nvim plugins. Safe to re-run (idempotent).
#
# Usage:
#   git clone https://github.com/chrisogles/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && ./linux-bootstrap.sh
#
# What this does NOT do (deliberately out of scope — set up manually if
# needed on this box):
#   - zsh / zinit (this setup is bash-only, see feedback in project memory:
#     fewer moving parts to break a remote session)
#   - AWS SSO / SSM tunnel / psql scaffolding (client-specific, needs
#     per-box credentials and instance lookups — not a blind repo pull)
#   - macOS-only dotfiles folders (aerospace, alacritty, ghostty) — stow_all.sh
#     will symlink them harmlessly, but nothing here installs the apps

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "==> Installing apt packages"
sudo apt-get update
sudo apt-get install -y \
  git neovim tmux fzf bat ripgrep fd-find zoxide stow \
  nodejs npm python3-venv build-essential curl

# eza replaced exa; package name differs by distro age. Try eza, fall back to exa.
if ! command -v eza >/dev/null 2>&1 && ! command -v exa >/dev/null 2>&1; then
  sudo apt-get install -y eza || sudo apt-get install -y exa || \
    echo "!! Neither eza nor exa available via apt — ls aliases will fall back to plain ls"
fi

echo "==> Installing starship prompt"
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" -y
fi

echo "==> Installing lazygit"
if ! command -v lazygit >/dev/null 2>&1; then
  LAZYGIT_VERSION="$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')"
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64) LAZYGIT_ARCH="x86_64" ;;
    aarch64|arm64) LAZYGIT_ARCH="arm64" ;;
    *) echo "!! Unrecognised arch $ARCH — install lazygit manually"; LAZYGIT_ARCH="" ;;
  esac
  if [ -n "$LAZYGIT_ARCH" ]; then
    mkdir -p "$HOME/.local/bin"
    curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
      | tar xz -C /tmp lazygit
    mv /tmp/lazygit "$HOME/.local/bin/lazygit"
  fi
fi

echo "==> Stowing dotfiles (tmux, nvim, bash — skips inspodots/raycast per stow_all.sh)"
./stow_all.sh

echo "==> Setting git identity"
git config --global user.name "Chris"
git config --global user.email "chris@solved.dev"

echo "==> Installing tmux plugin manager (TPM)"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || true

echo "==> Bootstrapping nvim plugins (this can take a minute — Mason/treesitter installs)"
nvim --headless "+Lazy! sync" +qa || true

echo "==> Done."
echo "Log out and back in over SSH to trigger the tmux auto-attach, or run: tmux attach -t main"
