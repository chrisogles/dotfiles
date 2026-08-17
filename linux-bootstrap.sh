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
# Machine-specific config (per-box PATH entries, host-only aliases, anything
# with a credential in it) belongs in ~/.bashrc.local — untracked, and sourced
# by the stowed ~/.bashrc. This script seeds an empty one if absent.
#
# What this does NOT do (deliberately out of scope — set up manually if
# needed on this box):
#   - zsh / zinit (this setup is bash-only, see feedback in project memory:
#     fewer moving parts to break a remote session)
#   - AWS SSO / SSM tunnel / psql scaffolding (client-specific, needs
#     per-box credentials and instance lookups — not a blind repo pull)
#   - macOS-only dotfiles folders (aerospace, alacritty, ghostty) — we stow an
#     explicit package list here rather than calling stow_all.sh, which is the
#     macOS entrypoint and would symlink those plus zsh
#   - tmux-thumbs' binary (needs a Rust toolchain; the plugin is downloaded but
#     its `prefix + space` hint-copy won't work until you `cargo build` it)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Packages to stow on Linux. Explicit list — see note above.
STOW_PACKAGES=(bash tmux nvim starship)

echo "==> Installing apt packages"
sudo apt-get update
sudo apt-get install -y \
  git tmux fzf bat ripgrep fd-find zoxide stow \
  nodejs npm python3-venv build-essential curl tar

# eza replaced exa; package name differs by distro age. Try eza, fall back to exa.
if ! command -v eza >/dev/null 2>&1 && ! command -v exa >/dev/null 2>&1; then
  sudo apt-get install -y eza || sudo apt-get install -y exa || \
    echo "!! Neither eza nor exa available via apt — ls aliases will fall back to plain ls"
fi

# Arch suffix used by the neovim and lazygit release tarballs.
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)        NVIM_ARCH="x86_64"; LAZYGIT_ARCH="x86_64" ;;
  aarch64|arm64) NVIM_ARCH="arm64";  LAZYGIT_ARCH="arm64"  ;;
  *)             NVIM_ARCH="";       LAZYGIT_ARCH=""       ;;
esac

# Neovim: NOT from apt. Ubuntu 24.04 ships 0.9.5, but this config is LazyVim
# with blink.cmp, which needs 0.10+. The apt build loads a broken config, and
# .bashrc aliases vim/vi/v -> nvim, so a bad nvim costs you your editor too.
# Official stable tarball into ~/.local/opt, symlinked onto PATH. No root.
echo "==> Installing neovim (official stable tarball)"
if ! command -v nvim >/dev/null 2>&1 || ! nvim --version | head -1 | grep -qE 'v0\.(1[0-9]|[2-9][0-9])'; then
  if [ -n "$NVIM_ARCH" ]; then
    mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
    curl -fsSL "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${NVIM_ARCH}.tar.gz" \
      -o /tmp/nvim.tar.gz
    rm -rf "$HOME/.local/opt/nvim"
    mkdir -p "$HOME/.local/opt/nvim"
    tar xzf /tmp/nvim.tar.gz -C "$HOME/.local/opt/nvim" --strip-components=1
    ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
    rm -f /tmp/nvim.tar.gz
  else
    echo "!! Unrecognised arch $ARCH — install neovim >= 0.10 manually"
  fi
fi

echo "==> Installing starship prompt"
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" -y
fi

echo "==> Installing lazygit"
if ! command -v lazygit >/dev/null 2>&1; then
  LAZYGIT_VERSION="$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')"
  if [ -n "$LAZYGIT_ARCH" ]; then
    mkdir -p "$HOME/.local/bin"
    curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
      | tar xz -C /tmp lazygit
    mv /tmp/lazygit "$HOME/.local/bin/lazygit"
  else
    echo "!! Unrecognised arch $ARCH — install lazygit manually"
  fi
fi

# Seed the untracked per-box override file so ~/.bashrc's source line has a
# target and there's an obvious place to put machine-local config.
if [ ! -f "$HOME/.bashrc.local" ]; then
  echo "==> Seeding ~/.bashrc.local (machine-specific, untracked)"
  cat > "$HOME/.bashrc.local" <<'EOF'
# ~/.bashrc.local — machine-specific bash config for THIS box.
# Not tracked in ~/dotfiles; sourced at the end of the stowed ~/.bashrc.
# Put per-box PATH entries, host-only aliases and anything secret here.

# Uncomment to stop this box auto-attaching to tmux on SSH login:
# NO_TMUX_AUTOATTACH=1
EOF
fi

# stow refuses to replace a real file, and with `set -e` that aborts the run.
# Move any pre-existing real dotfile out of the way first — a fresh Debian box
# always ships a stock ~/.bashrc, so this branch is the norm, not the edge case.
echo "==> Backing up conflicting dotfiles to ~/.dotfiles-backup"
BACKUP_DIR="$HOME/.dotfiles-backup"
mkdir -p "$BACKUP_DIR"
for pkg in "${STOW_PACKAGES[@]}"; do
  while IFS= read -r rel; do
    target="$HOME/$rel"
    # Only real files block stow; existing symlinks and dirs are fine.
    if [ -e "$target" ] && [ ! -L "$target" ] && [ ! -d "$target" ]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv -v "$target" "$BACKUP_DIR/$rel"
    fi
  done < <(cd "$pkg" && find . -type f -printf '%P\n')
done

echo "==> Stowing dotfiles: ${STOW_PACKAGES[*]}"
stow -t "$HOME" "${STOW_PACKAGES[@]}"

echo "==> Setting git identity (only if unset)"
git config --global user.name  >/dev/null 2>&1 || git config --global user.name "Chris Ogilvie"
git config --global user.email >/dev/null 2>&1 || git config --global user.email "chris@solved.dev"

echo "==> Installing tmux plugin manager (TPM)"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
# TPM's installer drives a running tmux server, so make sure one exists.
tmux new-session -d -s _bootstrap 2>/dev/null || true
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
tmux kill-session -t _bootstrap 2>/dev/null || true

echo "==> Bootstrapping nvim plugins (this can take a minute)"
# `+Lazy! sync` returns as soon as the plugin clones finish, so +qa kills
# Mason's downloads and treesitter's compiles mid-flight. Run the plugin sync
# first, then let Mason/treesitter finish on first real nvim launch — or run
# :Mason and :TSUpdate interactively once. Don't trust a clean exit here to
# mean the tool binaries landed.
nvim --headless "+Lazy! sync" +qa || true

echo
echo "==> Done."
echo "Toolchain:"
for c in nvim tmux starship lazygit eza zoxide fzf batcat rg stow; do
  printf "  %-10s %s\n" "$c" "$(command -v "$c" || echo 'MISSING')"
done
echo
echo "Backups of any replaced dotfiles: $BACKUP_DIR"
echo "Log out and back in over SSH to trigger the tmux auto-attach, or run: tmux new-session -A -s main"
