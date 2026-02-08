#!/bin/bash
set -e

echo "Start sha update"

git diff --name-only HEAD~1  | grep '^cluster/charts/.*\.nix$' | while IFS= read -r NIX_FILE; do
    echo "Processing $NIX_FILE"

    CHART_NAME=$(grep -o 'chart\s*=\s*"[^"]*"' "$NIX_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
    REPO_URL=$(grep -o 'repo\s*=\s*"[^"]*"' "$NIX_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
    VERSION=$(grep -o 'version\s*=\s*"[^"]*"' "$NIX_FILE" | sed -E 's/.*"([^"]+)".*/\1/')

    echo $REPO_URL
    echo $CHART_NAME
    echo $VERSION

    CURRENT_DIR=$(pwd)
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    cd "$TEMP_DIR"

    helm repo add temp-repo "$REPO_URL"
    helm repo update
    helm pull "temp-repo/$CHART_NAME" --version "$VERSION" --untar

    CHART_DIR=$(ls -d */ | head -1 | sed 's:/*$::')
    NIX_HASH=$(nix hash path "$CHART_DIR")

    echo $NIX_HASH

    cd "$CURRENT_DIR"
    sed -i "s|chartHash = \".*\"|chartHash = \"$NIX_HASH\"|" "$NIX_FILE"
done

