#!/usr/bin/env bash
set -euo pipefail

REPO="ildysilva/xpoz_cli"
BIN="xpoz"
INSTALL_DIR="/usr/local/bin"

# Detect SO
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  linux)  OS_TAG="linux" ;;
  darwin) OS_TAG="darwin" ;;
  *) echo "❌ Unsupported OS: $OS"; exit 1 ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH_TAG="amd64" ;;
  arm64|aarch64) ARCH_TAG="arm64" ;;
  *) echo "❌ Unsupported arch: $ARCH"; exit 1 ;;
esac

VERSION="${1:-latest}"
if [[ "$VERSION" = "latest" ]]; then
  # Preferência: jq (se existir); fallback para sed
  if command -v jq >/dev/null 2>&1; then
    VERSION="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)"
  else
    VERSION="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
      | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p')"
  fi
fi


ASSET="${BIN}-${OS_TAG}-${ARCH_TAG}"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"

echo "➡️  Installing ${BIN} ${VERSION} (${OS_TAG}/${ARCH_TAG})"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "⬇️  Downloading $URL"
curl -fL "$URL" -o "$TMP/$BIN"
chmod +x "$TMP/$BIN"

if [[ -w "$INSTALL_DIR" ]] || sudo -v >/dev/null 2>&1; then
  echo "📦 Installing to $INSTALL_DIR"
  sudo mv "$TMP/$BIN" "$INSTALL_DIR/$BIN"
else
  echo "📦 No sudo. Installing to \$HOME/.xpoz/bin"
  INSTALL_DIR="$HOME/.xpoz/bin"
  mkdir -p "$INSTALL_DIR"
  mv "$TMP/$BIN" "$INSTALL_DIR/$BIN"
  if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc" 2>/dev/null || true
    echo "⚠️  Added $INSTALL_DIR to PATH. Restart your shell."
  fi
fi

echo "✅ Installed: $(command -v $BIN)"
$BIN --version || true
