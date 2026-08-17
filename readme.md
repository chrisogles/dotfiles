# My Project Repo

## Overview

This is a git repo for my settings files across Mac, Linux, and Windows.

## Getting Started

To get started with this project on a new machine, follow these steps:

### Cloning the Repository

1. Open a terminal on your machine.
2. Clone the repository using the following command:

```
git clone https://github.com/chrisogles/dotfiles.git
```

### Connecting to the Repository

1. Navigate to the directory where you cloned the repository.

### macOS: run Stow to install all dotfiles into $HOME

1. Run command:

```
stow_all.sh
```

This will iteratively install the dotfile folders into the home directory.
`stow_all.sh` is the **macOS** entrypoint — it stows every folder (including
`aerospace`, `alacritty`, `ghostty` and `zsh`) and will install stow via
Homebrew if it's missing. On Linux use `linux-bootstrap.sh` instead, which
stows an explicit Linux-relevant subset.

## Linux / TMUX / NVIM Settings

For a fresh Debian/Ubuntu box (terminal productivity setup — tmux, nvim,
bash aliases, auto-attach-tmux-on-SSH — no AWS/psql scaffolding, no
GUI/Mac-only stuff):

```
git clone https://github.com/chrisogles/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./linux-bootstrap.sh
```

Installs the apt/standalone-binary toolchain, backs up any conflicting real
dotfiles to `~/.dotfiles-backup`, stows `bash tmux nvim starship`, sets git
identity if unset, and installs tmux plugins (TPM) and nvim plugins
(lazy.nvim). Safe to re-run. See the script's header comment for what's
deliberately out of scope (zsh/zinit, AWS SSO/SSM tunnels — those need
per-box setup, not a blind repo pull).

Neovim comes from the **official stable tarball**, not apt: Ubuntu 24.04
ships 0.9.5 and this config needs 0.10+ for `blink.cmp`. Since `.bashrc`
aliases `vim`/`vi`/`v` to `nvim`, an apt neovim costs you your editor too.

### Machine-specific config: ~/.bashrc.local

The stowed `~/.bashrc` sources `~/.bashrc.local` at the end if it exists.
That file is **not tracked here** — it's where per-box PATH entries,
host-only aliases and anything with a credential in it belong, so this repo
stays identical across machines. `linux-bootstrap.sh` seeds an empty one.

Set `NO_TMUX_AUTOATTACH=1` there to stop a given box auto-attaching to tmux
on SSH login (useful for a box you mostly scp to, or a CI runner).

### Known gaps on Linux

- **tmux-thumbs** (`prefix + space` hint-copy) needs a Rust toolchain to
  build its binary. TPM downloads the plugin but the keybinding is inert
  until you `cd ~/.tmux/plugins/tmux-thumbs && cargo build --release`.
- **Mason / treesitter** don't finish inside `nvim --headless "+Lazy! sync"
  +qa` — nvim exits while their downloads are still running. Run `:Mason`
  and `:TSUpdate` once interactively after the first launch.

## VSCode Settings and Keybindings

:TODO
