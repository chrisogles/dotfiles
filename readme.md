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

### Run Stow to install all dotfiles into $HOME directory

1. Run command:

```
stow_all.sh
```

This will iteratively install the dotfile folders into the home directory.

## Linux / TMUX / NVIM Settings

For a fresh Debian/Ubuntu box (terminal productivity setup — tmux, nvim,
bash aliases, auto-attach-tmux-on-SSH — no AWS/psql scaffolding, no
GUI/Mac-only stuff):

```
git clone https://github.com/chrisogles/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./linux-bootstrap.sh
```

Installs the apt/standalone-binary toolchain, stows the dotfiles, sets git
identity, installs tmux plugins (TPM) and nvim plugins (lazy.nvim). Safe to
re-run. See the script's header comment for what's deliberately out of
scope (zsh/zinit, AWS SSO/SSM tunnels — those need per-box setup, not a
blind repo pull).

If you're a Claude Code session reading this on a new box: run
`./linux-bootstrap.sh` from `~/dotfiles`, then tell the user it's done and
that they should reconnect over SSH to trigger the tmux auto-attach.

## VSCode Settings and Keybindings

:TODO
