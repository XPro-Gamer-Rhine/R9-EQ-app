#!/bin/bash
# R9-EQ installer — installs the latest release into Applications and launches it.
#
# Usage (paste into Terminal):
#   curl -fsSL https://raw.githubusercontent.com/XPro-Gamer-Rhine/R9-EQ-app/main/install.sh | bash
#
# Why this exists: R9-EQ is free and ad-hoc signed (no paid Apple Developer
# account). A BROWSER download gets the com.apple.quarantine flag, and on
# macOS 15+ Gatekeeper then blocks/trashes the app on first double-click.
# curl does NOT set the quarantine flag, so an app installed this way launches
# like any normal app — no Gatekeeper dialog, nothing moved to the Trash.
set -euo pipefail

REPO="XPro-Gamer-Rhine/R9-EQ-app"
TARBALL_URL="https://github.com/$REPO/releases/latest/download/R9-EQ.tar.gz"

# --- macOS version check (audio engine needs 14.4+) ---------------------------
OSVER="$(sw_vers -productVersion)"
MAJOR="${OSVER%%.*}"; REST="${OSVER#*.}"; MINOR="${REST%%.*}"
[ "$MAJOR" = "$OSVER" ] && MINOR=0
if [ "$MAJOR" -lt 14 ] || { [ "$MAJOR" -eq 14 ] && [ "$MINOR" -lt 4 ]; }; then
  echo "R9-EQ needs macOS 14.4 or later (you have $OSVER) — the system-wide"
  echo "audio engine uses Core Audio process taps introduced in 14.4."
  exit 1
fi

# --- Destination: /Applications, or ~/Applications if not writable -------------
DEST_DIR="/Applications"
if [ ! -w "$DEST_DIR" ]; then
  DEST_DIR="$HOME/Applications"
  mkdir -p "$DEST_DIR"
fi
APP="$DEST_DIR/R9-EQ.app"

# --- Download + extract --------------------------------------------------------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "==> Downloading R9-EQ (latest release)..."
curl -fL --progress-bar "$TARBALL_URL" -o "$TMP/R9-EQ.tar.gz"
tar -xzf "$TMP/R9-EQ.tar.gz" -C "$TMP"
[ -d "$TMP/R9-EQ.app" ] || { echo "ERROR: archive did not contain R9-EQ.app"; exit 1; }

# --- Install (replace any old copy, quit a running one first) ------------------
echo "==> Installing to $DEST_DIR ..."
osascript -e 'tell application "R9-EQ" to quit' >/dev/null 2>&1 || true
/usr/bin/pkill -x EQ 2>/dev/null || true
rm -rf "$APP"
mv "$TMP/R9-EQ.app" "$APP"

# curl'd files carry no quarantine flag; strip defensively anyway (covers a
# previously browser-downloaded copy that was already in Applications).
/usr/bin/xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

# --- Launch --------------------------------------------------------------------
echo "==> Launching..."
open "$APP"
echo ""
echo "✅ R9-EQ installed at $APP"
echo "   1. Click the R9 icon in the menu bar (top-right)."
echo "   2. Press the power button to start the EQ."
echo "   3. Approve “System Audio Recording” when macOS asks (required)."
