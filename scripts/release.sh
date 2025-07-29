#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: release.sh vX.Y.Z}"

# 1) Tag
git add -A
git commit -m "release: ${VERSION}" || true
git tag "${VERSION}" || true
git push origin main --tags

bash scripts/build_all.sh

( cd dist && (shasum -a 256 * 2>/dev/null || sha256sum *) > checksums.txt )

gh release create "${VERSION}" dist/* --notes "Xpoz CLI ${VERSION}"
