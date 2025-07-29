#!/usr/bin/env bash
set -euo pipefail

# Limpa dist
rm -rf dist
mkdir -p dist

echo "🔧 Building (host OS/arch)…"

# Detecta SO/arch
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

TARGET=""
case "$OS" in
  linux)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then TARGET="linux-amd64"; fi
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then TARGET="linux-arm64"; fi
    ;;
  darwin)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then TARGET="darwin-amd64"; fi
    if [[ "$ARCH" == "arm64" ]]; then TARGET="darwin-arm64"; fi
    ;;
esac

if [[ -z "$TARGET" ]]; then
  echo "❌ Unsupported host combination: $OS/$ARCH"
  exit 1
fi

echo "➡️  dart compile exe bin/xpoz.dart -o dist/xpoz-$TARGET"
dart pub get
dart compile exe bin/xpoz.dart -o "dist/xpoz-$TARGET"

echo "✅ Built dist/xpoz-$TARGET"
ls -lh dist/
