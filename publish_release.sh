#!/bin/bash
set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing arguments."
    echo "Usage: ./publish_release.sh <marketing_version> <build_number>"
    echo "Example: ./publish_release.sh 1.6 1"
    exit 1
fi

VERSION="$1"
BUILD_NUMBER="$2"
TAG="v$VERSION"

# 1. Double check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it via: brew install gh"
    echo "Alternatively, you can just push a tag and let GitHub Actions compile and release for you."
    exit 1
fi

# 2. Re-build and package the release assets locally
echo "=== Packaging assets locally for $VERSION (Build: $BUILD_NUMBER) ==="
bash release.sh "$VERSION" "$BUILD_NUMBER"

# 3. Commit update.json
echo "=== Committing release config changes ==="
git add update.json
git commit -m "Bump update.json to $TAG" || true

# 4. Tag and push changes
echo "=== Tagging commit as $TAG and pushing to remote ==="
git tag -d "$TAG" 2>/dev/null || true
git tag -a "$TAG" -m "Release $TAG"

echo "=== Pushing commits and tag to GitHub ==="
git push origin main || true
git push origin -f "$TAG" || true

# 5. Create release via GitHub CLI
echo "=== Publishing Release $TAG on GitHub ==="
gh release create "$TAG" AdvancedDock.dmg AdvancedDock.zip \
    --title "$TAG" \
    --notes "Release of version $VERSION (Build $BUILD_NUMBER)." \
    --clobber

echo "=== Release $TAG published successfully! ==="
