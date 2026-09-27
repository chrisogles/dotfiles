# Omarchy (Arch + Hyprland) setup

Entrypoint for an **Omarchy** box — as opposed to `linux-bootstrap.sh`, which
targets Debian/Ubuntu and would be wrong here twice over: it installs with
`apt`, and it stows `bash tmux nvim starship` over files that Omarchy already
owns and rewrites.

```
cd ~/.dotfiles/omarchy && ./apply.sh
```

Safe to re-run. Every edit it makes to an Omarchy-owned file is wrapped in
`>>> dotfiles/omarchy` / `<<< dotfiles/omarchy` markers, so a re-run replaces
its own block instead of appending a second copy. Originals are copied to
`~/.dotfiles-backup/omarchy-<timestamp>/` on first run.

## Why this isn't stow

On Omarchy these are not free real estate:

| File | Who owns it | What breaks if you stow over it |
|------|-------------|--------------------------------|
| `~/.bashrc` | Omarchy | Sources `$OMARCHY_PATH/default/bash/rc`, which activates **mise**. Replacing it removes `claude`, `gh` and `node` from PATH. |
| `~/.config/tmux/tmux.conf` | Omarchy | Ctrl-Space prefix, Alt-key window/pane bindings, the `?` keybindings popup. Also: a stowed `~/.tmux.conf` silently *wins*, because tmux reads that path first. |
| `~/.config/nvim` | Omarchy (LazyVim + theme hot-reload) | Theme switching (`omarchy theme set`) drives nvim's colorscheme through `plugins/theme.lua` + `plugins/omarchy-theme-hotreload.lua`. |
| `~/.config/alacritty`, `~/.config/ghostty` | Omarchy | Both import the live theme from `~/.local/state/omarchy/current/theme/`. |

So `apply.sh` **appends to** or **merges into** those files rather than
symlinking over them.

## What it applies

- **bash** — the personal aliases from `bash/.bashrc` that Omarchy doesn't
  already provide. Omarchy's own `ls`/`lt` (eza), zoxide, starship, fzf and
  mise setup are left alone. Note `c` is overridden to `clear` (Omarchy ships
  `c=opencode --auto`).
- **tmux** — vim-aware Ctrl-h/j/k/l pane navigation (the vim-tmux-navigator
  snippet, no TPM), Alt-Shift-h/l window switching, repeatable prefix +
  Alt-hjkl resizing, dimmed inactive panes. Ctrl-l is now a pane move, so
  clear-screen becomes **prefix + Ctrl-l**.
- **nvim** — copies a subset of this repo's `nvim` plugin specs on top of
  Omarchy's LazyVim, plus the options and keymaps. Deliberately excluded:
  - `colorscheme.lua` and `lualine.lua` — hardcode a theme, fighting Omarchy's
    theme hot-reload.
  - `treesitter.lua` — pins nvim-treesitter to `master`; Omarchy ships LazyVim
    16, which expects the `main` branch. `flash.lua` already moves incremental
    selection off `<C-space>` (the tmux prefix) on LazyVim >= 15.
  - `notion.lua`, `config/zettelkasten.lua` — need a Notion API key and `zk`.
  - `lang.java`, `lang.docker`, `ui.mini-animate` extras — memory and no docker.
  - Keymaps calling tools that aren't installed (`gendate`, textcase, GoTest)
    and the cmp toggles (this config is on blink.cmp).
  - `lazy-lock.json` — Mac-authoritative, see the top-level readme.
- **Hyprland** — web app keybindings (Gmail / Calendar / Slack / Notion /
  Claude, replacing the HEY and ChatGPT defaults), animations off, and an
  evening night-light profile with `hyprsunset` started at login.
- **Web apps** — installs Gmail, Google Calendar, Slack, Notion and Claude as
  Chromium `--app` launchers (one browser process, one login) and removes the
  Omarchy preinstalls that go unused.
- **Power profiles** — `balanced` on AC, `power-saver` on battery.

## Hardware-specific

`hardware/macbook-air-6-1.sh` is for the 2013 MacBook Air (`MacBookAir6,1`,
Haswell i5-4250U, 4 GB RAM) only — hardware video decode, fan control, SSD
TRIM, and switching off services that machine doesn't need. Run it after
`apply.sh`, in a terminal (it needs sudo).

## Known-bad on that MacBook Air

**Hibernation does not resume.** Omarchy sets it up and the image writes fine,
but the firmware hands back a different memory map on the next boot and the
kernel discards it:

```
Hibernate inconsistent memory map detected!
PM: hibernation: Image mismatch: architecture specific data
PM: hibernation: resume failed (-1)
```

So the lid must stay on plain `suspend` — do **not** set
`HandleLidSwitch=suspend-then-hibernate`, or 45 minutes with the lid shut
silently loses the session. `deep` suspend on that machine is frugal enough.
