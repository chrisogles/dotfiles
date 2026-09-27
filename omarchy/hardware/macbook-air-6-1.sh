#!/usr/bin/env bash
# Hardware tuning for a 2013 MacBook Air (MacBookAir6,1 — Haswell i5-4250U,
# 4 GB RAM, HD 5000 graphics, 1366x768) running Omarchy.
#
# Run as your user, in a terminal (it needs sudo, and the AUR build must not run
# as root):
#   ~/.dotfiles/omarchy/hardware/macbook-air-6-1.sh
#
# Safe to re-run. See ../README.md for the hibernation warning — that machine
# writes a hibernation image fine but cannot resume from it.
set -euo pipefail

if [ "$(cat /sys/class/dmi/id/product_name 2>/dev/null)" != "MacBookAir6,1" ]; then
  echo "This script is specific to MacBookAir6,1. Detected: $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo unknown)" >&2
  read -rp "Continue anyway? [y/N] " reply
  [[ ${reply:-} == [yY] ]] || exit 1
fi

echo "==> Hardware video decode (Haswell = i965, and H.264 only)"
# Without this, Chromium decodes video on a 1.3 GHz dual-core CPU. libva-utils
# is here for vainfo, to verify the driver actually loaded.
omarchy pkg add libva-intel-driver libva-utils

echo "==> Chromium flags for VA-API"
CONF="$HOME/.config/chromium-flags.conf"
if [ -f "$CONF" ] && grep -q '^--enable-features=' "$CONF"; then
  for feature in AcceleratedVideoDecodeLinuxGL AcceleratedVideoDecodeLinuxZeroCopyGL VaapiIgnoreDriverChecks; do
    grep -q "$feature" "$CONF" || sed -i "s/^--enable-features=.*/&,$feature/" "$CONF"
  done
  echo "  flags set"
else
  echo "  !! no --enable-features line in $CONF; add the VA-API features manually" >&2
fi

echo "==> enhanced-h264ify (this GPU can only hardware-decode H.264)"
# YouTube serves VP9/AV1 by default, which this chip decodes in software. The
# extension is loaded unpacked via --load-extension, matching how Omarchy ships
# its own extensions; it therefore won't auto-update.
EXT_DIR="$HOME/.local/share/chromium-extensions/enhanced-h264ify"
EXT_ID="omkfmpieigblcllmkgbflkikinpkodlk"
if [ ! -f "$EXT_DIR/manifest.json" ]; then
  mkdir -p "$EXT_DIR"
  curl -sSL -o "$EXT_DIR/ext.crx" \
    "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=152.0&acceptformat=crx2,crx3&x=id%3D${EXT_ID}%26uc"
  (cd "$EXT_DIR" && unzip -oq ext.crx 2>/dev/null || true)
  rm -rf "$EXT_DIR/ext.crx" "$EXT_DIR/_metadata"
fi
if [ -f "$EXT_DIR/manifest.json" ] && ! grep -q "chromium-extensions/enhanced-h264ify" "$CONF" 2>/dev/null; then
  sed -i "s|^--load-extension=.*|&,$EXT_DIR|" "$CONF"
  echo "  extension loaded on next Chromium start"
fi

echo "==> Weekly SSD TRIM"
sudo systemctl enable --now fstrim.timer

echo "==> Services this machine doesn't need"
sudo systemctl disable --now cups.service cups.socket cups.path cups-browsed.service 2>/dev/null || true
sudo systemctl disable --now avahi-daemon.service avahi-daemon.socket 2>/dev/null || true
sudo systemctl disable --now bolt.service 2>/dev/null || true
sudo systemctl mask bolt.service

echo "==> Fan control (applesmc's firmware curve runs hot and throttles)"
omarchy pkg aur add mbpfan-git
sudo systemctl enable --now mbpfan.service

echo
echo "==> Done. Video decode check:"
vainfo 2>&1 | grep -E 'Driver version|VAProfileH264Main' | head -3 || true
cat <<'EOF'

Then: restart Chromium and confirm hardware decode at chrome://media-internals
(look for VaapiVideoDecoder while a YouTube video plays).

Not done here, on purpose:
  - Hibernation: the lid must stay on plain suspend (see ../README.md).
  - mitigations=off: worth 5-15% on Haswell, but it disables Spectre-class
    mitigations. Decide per machine; not applied blindly by a script.
EOF
