#!/usr/bin/env bash
set -euo pipefail

echo "=== OS ==="
cat /etc/os-release

echo
echo "=== Kernel ==="
uname -a

echo
echo "=== NVIDIA ==="
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi
else
    echo "nvidia-smi is not installed or not in PATH."
fi

echo
echo "=== Block devices ==="
lsblk -o NAME,MODEL,SERIAL,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS

echo
echo "=== Filesystems ==="
df -hT

echo
echo "=== Network addresses ==="
ip -br address

echo
echo "=== Default route ==="
ip route show default
