#!/bin/bash
# Script to build NetBird mobile bindings using gomobile
# Usage: ./script.sh [version]
# If no version is provided, "development" is used as default
set -e

app_path=$(pwd)


get_version() {
  if [ -n "$1" ]; then
    echo "$1"
    return
  fi

  # Try to get an exact tag
  local tag=$(git describe --tags --exact-match 2>/dev/null || true)

  if [ -n "$tag" ]; then
    cd - > /dev/null
    echo "$tag"
    return
  fi

  # Fallback to "development-<short-hash>"
  local short_hash=$(git rev-parse --short HEAD)
  local new_version="development-$short_hash"

  echo "$new_version"
}


cd netbird

# Get version using the function
version=$(get_version "$1")
echo "Using version: $version"
exit
gomobile init

CGO_ENABLED=0 gomobile bind \
  -o $app_path/gomobile/netbird.aar \
  -javapkg=io.netbird.gomobile \
  -ldflags="-checklinkname=0 -X golang.zx2c4.com/wireguard/ipc.socketDirectory=/data/data/io.netbird.client/cache/wireguard -X github.com/netbirdio/netbird/version.version=$version" \
  $(pwd)/client/android

cd - > /dev/null
