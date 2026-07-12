#!/bin/bash
set -e

# Production Versioning Defaults
VERSION="1.6"
BUILD_NUMBER="1"

# Read version and build arguments if provided
if [ ! -z "$1" ]; then
    VERSION="$1"
fi
if [ ! -z "$2" ]; then
    BUILD_NUMBER="$2"
fi

# Get repository details from remote URL
REMOTE_URL=$(git config --get remote.origin.url || true)
OWNER="nikhilJa1n"
REPO="Advanced-Dock"
if [[ "$REMOTE_URL" =~ github.com[:/]([^/]+)/([^.]+)(.git)? ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
fi

echo "=== Packaging AdvancedDock for Release (Version: $VERSION, Build: $BUILD_NUMBER) ==="
bash build.sh "$VERSION" "$BUILD_NUMBER"

# Check compile outputs
if [ ! -d "AdvancedDock.app" ] || [ ! -f "AdvancedDock.dmg" ]; then
    echo "Error: Build artifacts not generated correctly."
    exit 1
fi

# Create ZIP archive (.zip) as fallback
echo "=== Creating ZIP Archive (AdvancedDock.zip) ==="
rm -f AdvancedDock.zip
zip -r -y -q AdvancedDock.zip AdvancedDock.app

# Update update.json configuration
echo "=== Updating update.json ==="
cat > update.json <<EOF
{
  "version": "$VERSION",
  "downloadUrl": "https://github.com/$OWNER/$REPO/releases/download/v$VERSION/AdvancedDock.dmg",
  "changelog": "Released version $VERSION."
}
EOF

# Summary
echo "=== Release Packages Created Successfully ==="
ls -lh AdvancedDock.dmg AdvancedDock.zip
