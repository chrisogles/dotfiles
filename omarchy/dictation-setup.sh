#!/usr/bin/env bash
# Install Voxtype dictation with LLM cleanup, tuned for a low-spec machine.
#
# Run as your user, in a terminal (the package install needs sudo):
#   ~/.dotfiles/omarchy/dictation-setup.sh
#
# What this sets up:
#   - voxtype + wtype, with the base.en whisper model (~142 MB)
#   - on-demand model loading, so an idle daemon doesn't hold the model in RAM
#   - transcripts piped through ~/.local/bin/voxtype-cleanup.sh, which uses the
#     claude CLI (Haiku, remote inference) for punctuation and filler removal —
#     the usual local-Ollama recipe is unusable on 4 GB
#
# Keys come from Omarchy's own bindings and appear once voxtype is installed:
#   F9 (hold)        push-to-talk
#   Super+Ctrl+X     toggle
#
# Safe to re-run. Switch cleanup to local-only (nothing leaves the machine) with:
#   touch ~/.config/voxtype/no-llm
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v omarchy >/dev/null 2>&1; then
  echo "Not an Omarchy box." >&2
  exit 1
fi

echo "==> Installing Voxtype (this downloads the whisper model)"
if command -v voxtype >/dev/null 2>&1; then
  echo "  voxtype already installed"
else
  # Omarchy's installer handles the package, the model download and the systemd
  # user service, and enables Vulkan acceleration where the GPU supports it.
  omarchy voxtype install
fi

echo "==> Installing the cleanup post-processor"
install -Dm755 "$HERE/files/voxtype-cleanup.sh" "$HOME/.local/bin/voxtype-cleanup.sh"

echo "==> Installing the tuned config"
mkdir -p "$HOME/.config/voxtype"
if [ -f "$HOME/.config/voxtype/config.toml" ]; then
  cp -a "$HOME/.config/voxtype/config.toml" \
    "$HOME/.config/voxtype/config.toml.bak.$(date +%Y%m%d%H%M%S)"
fi
sed "s|__HOME__|$HOME|g" "$HERE/files/voxtype-config.toml" \
  >"$HOME/.config/voxtype/config.toml"

echo "==> Restarting the daemon"
systemctl --user daemon-reload
systemctl --user restart voxtype.service 2>/dev/null || systemctl --user start voxtype.service
hyprctl reload >/dev/null 2>&1 || true

echo
echo "==> Done."
cat <<'EOF'
Try it: put the cursor in a text field, hold F9, say
  "this is a test comma and it should have punctuation full stop"
then release.

First run after boot is slower — the model loads on first use by design.

Check it's healthy:        systemctl --user status voxtype
Test cleanup on its own:   echo "um so like this is a test" | ~/.local/bin/voxtype-cleanup.sh
Local-only cleanup:        touch ~/.config/voxtype/no-llm
Back to LLM cleanup:       rm ~/.config/voxtype/no-llm
Faster, less accurate:     set model = "tiny.en" in ~/.config/voxtype/config.toml
Model picker TUI:          omarchy voxtype model
EOF
