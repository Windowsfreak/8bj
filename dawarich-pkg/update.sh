#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bundix curl jq nix-update nix-prefetch-github prefetch-npm-deps gnused
set -e
set -o pipefail

OWNER="Freika"
REPO="dawarich"
VERSION="${1:-1.8.1}"

# Clean up version string (v1.8.1 -> 1.8.1)
VERSION="${VERSION#v}"

echo "Updating Dawarich to version v$VERSION"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "Prefetching source code for tag v$VERSION..."
JSON=$(nix-prefetch-github "$OWNER" "$REPO" --rev "refs/tags/v$VERSION" 2>/dev/null)
HASH=$(echo "$JSON" | jq -r .hash)

cat > "$SCRIPT_DIR/sources.json" << EOF
{
  "version": "$VERSION",
  "hash": "$HASH",
  "npmHash": "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
}
EOF

# Build only the src derivation so we can access Gemfile.lock and package-lock.json
echo "Building source derivation..."
SOURCE_DIR="$(nix-build --no-out-link -E "with import <nixpkgs> {}; callPackage $SCRIPT_DIR/package.nix {}" --attr src)"

echo "Generating gemset.nix..."
bundix --lockfile="$SOURCE_DIR/Gemfile.lock" --gemfile="$SOURCE_DIR/Gemfile" --gemset="$SCRIPT_DIR/gemset.nix"

echo "Prefetching npm dependencies..."
NPM_HASH="$(prefetch-npm-deps "$SOURCE_DIR/package-lock.json" 2>/dev/null)"
sed -i "s;sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=;$NPM_HASH;g" "$SCRIPT_DIR/sources.json"

echo "Successfully updated to v$VERSION!"
