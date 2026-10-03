#!/bin/bash
set -e

echo "Start sha update"

git diff --name-only HEAD~1 | grep '^cluster/charts/.*\.nix$' | while IFS= read -r NIX_FILE; do
    echo "Processing $NIX_FILE"

    CHART_NAME=$(grep -m1 -o 'chart\s*=\s*"[^"]*"' "$NIX_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
    REPO_URL=$(grep -m1 -o 'repo\s*=\s*"[^"]*"' "$NIX_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
    VERSION=$(grep -m1 -o 'version\s*=\s*"[^"]*"' "$NIX_FILE" | sed -E 's/.*"([^"]+)".*/\1/')

    echo $REPO_URL
    echo $CHART_NAME
    echo $VERSION

    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    CHART_PARENT_DIR="$TEMP_DIR/chart"

    if [[ "$REPO_URL" == oci://* ]]; then
        helm pull "${REPO_URL%/}/$CHART_NAME" --version "$VERSION" --untar --untardir "$CHART_PARENT_DIR"
    else
        helm repo add temp-repo "$REPO_URL"
        helm repo update
        helm pull "temp-repo/$CHART_NAME" --version "$VERSION" --untar --untardir "$CHART_PARENT_DIR"
    fi

    NIX_HASH=$(nix hash path "$CHART_PARENT_DIR/$CHART_NAME")

    echo $NIX_HASH

    sed -i "s|chartHash = \".*\"|chartHash = \"$NIX_HASH\"|" "$NIX_FILE"
    rm -rf "$TEMP_DIR"
    trap - EXIT
done
