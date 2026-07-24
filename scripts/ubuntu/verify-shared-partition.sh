#!/usr/bin/env bash
set -euo pipefail

LABEL="Dual_Boot_Share"

echo "=== Searching for $LABEL ==="
device="$(blkid -L "$LABEL" 2>/dev/null || true)"

if [[ -z "$device" ]]; then
    echo "Partition label not found: $LABEL"
    exit 1
fi

echo "Device: $device"

echo
echo "=== Filesystem metadata ==="
lsblk -f "$device"

echo
echo "=== Mount state ==="
findmnt "$device" || echo "The partition is not currently mounted."

echo
echo "=== UUID ==="
blkid "$device"
