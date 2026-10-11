#!/usr/bin/env bash
set -euo pipefail

TARGET="${ADOS_TARGET:-unknown}"
ROOT="${ADOS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
PORTABLE="$ROOT/portable"

mkdir -p "$TARGET_DIR/etc" "$TARGET_DIR/etc/ados" "$TARGET_DIR/usr/share/ados/portable"
printf '%s\n' "$TARGET" > "$TARGET_DIR/etc/ados-target"

cat > "$TARGET_DIR/etc/os-release" <<EOF
NAME="ADOS"
ID=ados
PRETTY_NAME="ADOS ($TARGET)"
VERSION="0.1-dev"
VERSION_ID="0.1-dev"
HOME_URL="https://github.com/AirysDark/ADOS"
EOF

# portable/ is the source of truth. Every build snapshots the complete
# portable tree into the OS for documentation/protocol/firmware reference.
rm -rf "$TARGET_DIR/usr/share/ados/portable"
mkdir -p "$TARGET_DIR/usr/share/ados/portable"
cp -a "$PORTABLE/." "$TARGET_DIR/usr/share/ados/portable/"

# Install Pi runtime assets from portable/rpi when present.
if [ -f "$PORTABLE/rpi/portable.conf" ]; then
    cp "$PORTABLE/rpi/portable.conf" "$TARGET_DIR/etc/ados/portable.conf"
elif [ -f "$PORTABLE/rpi/portable.conf.example" ]; then
    cp "$PORTABLE/rpi/portable.conf.example" "$TARGET_DIR/etc/ados/portable.conf"
fi

for runtime in ados-portabled ados-portable-gatt; do
    if [ -f "$PORTABLE/rpi/$runtime" ]; then
        install -m 0755 "$PORTABLE/rpi/$runtime" "$TARGET_DIR/usr/bin/$runtime"
    fi
done

if [ -d "$PORTABLE/rpi/rootfs-overlay" ]; then
    cp -a "$PORTABLE/rpi/rootfs-overlay/." "$TARGET_DIR/"
fi

# Record exactly which portable tree was embedded.
if command -v git >/dev/null 2>&1; then
    git -C "$ROOT" rev-parse HEAD 2>/dev/null > "$TARGET_DIR/usr/share/ados/portable-build-commit" || true
fi

# Portable is an ADOS core subsystem: fail the image build if its required
# source-of-truth runtime is incomplete.
for required in \
    "$PORTABLE/README.md" \
    "$PORTABLE/protocol/APDP.md" \
    "$PORTABLE/rpi/ados-portabled" \
    "$PORTABLE/rpi/ados-portable-gatt" \
    "$PORTABLE/rpi/portable.conf.example"; do
    if [ ! -s "$required" ]; then
        echo "ERROR: required ADOS Portable source missing: $required" >&2
        exit 1
    fi
done

for installed in \
    "$TARGET_DIR/usr/bin/ados-portabled" \
    "$TARGET_DIR/usr/bin/ados-portable-gatt" \
    "$TARGET_DIR/etc/ados/portable.conf"; do
    if [ ! -s "$installed" ]; then
        echo "ERROR: ADOS Portable runtime not installed: $installed" >&2
        exit 1
    fi
done

# Verify Portable interpreter/runtime prerequisites exist in the generated rootfs.
for binary in python3 bluetoothctl hostapd iw ip; do
    if [ ! -e "$TARGET_DIR/usr/bin/$binary" ] && [ ! -e "$TARGET_DIR/usr/sbin/$binary" ] && [ ! -e "$TARGET_DIR/sbin/$binary" ] && [ ! -e "$TARGET_DIR/bin/$binary" ]; then
        echo "ERROR: ADOS Portable dependency missing from rootfs: $binary" >&2
        exit 1
    fi
done
