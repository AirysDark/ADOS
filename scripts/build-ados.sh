#!/usr/bin/env bash
set -euo pipefail

BUILDROOT_VERSION="2025.02.18"
RPI_KERNEL_BRANCH="rpi-6.12.y"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE="${ADOS_CACHE:-$ROOT/.cache}"
BR_DIR="$CACHE/buildroot-$BUILDROOT_VERSION"
OUT_BASE="${ADOS_OUTPUT:-$ROOT/output}"

TARGET="${1:-}"
EXTRA_FRAGMENT=""
case "$TARGET" in
  rpi3-32)       BASE_DEFCONFIG="raspberrypi3_defconfig" ;;
  rpi3-64)       BASE_DEFCONFIG="raspberrypi3_64_defconfig" ;;
  rpi3b-b0-32)   BASE_DEFCONFIG="raspberrypi3_defconfig"; EXTRA_FRAGMENT="$ROOT/kernel/configs/ados-rpi3b-b0.config" ;;
  rpi3b-b0-64)   BASE_DEFCONFIG="raspberrypi3_64_defconfig"; EXTRA_FRAGMENT="$ROOT/kernel/configs/ados-rpi3b-b0.config" ;;
  rpi3bplus-32)  BASE_DEFCONFIG="raspberrypi3_defconfig" ;;
  rpi3bplus-64)  BASE_DEFCONFIG="raspberrypi3_64_defconfig" ;;
  rpi4-32)       BASE_DEFCONFIG="raspberrypi4_defconfig" ;;
  rpi4-64)       BASE_DEFCONFIG="raspberrypi4_64_defconfig" ;;
  *) echo "Usage: $0 {rpi3-32|rpi3-64|rpi3b-b0-32|rpi3b-b0-64|rpi3bplus-32|rpi3bplus-64|rpi4-32|rpi4-64}" >&2; exit 2 ;;
esac

mkdir -p "$CACHE" "$OUT_BASE"
if [ ! -d "$BR_DIR" ]; then
  ARCHIVE="$CACHE/buildroot-$BUILDROOT_VERSION.tar.xz"
  [ -f "$ARCHIVE" ] || curl -fL "https://buildroot.org/downloads/buildroot-$BUILDROOT_VERSION.tar.xz" -o "$ARCHIVE"
  tar -C "$CACHE" -xf "$ARCHIVE"
fi

OUT="$OUT_BASE/$TARGET"
rm -rf "$OUT"; mkdir -p "$OUT"
make -C "$BR_DIR" O="$OUT" "$BASE_DEFCONFIG"
CFG="$OUT/.config"
SCRIPTS_CONFIG="$BR_DIR/support/kconfig/scripts/config"
FRAGMENTS="$ROOT/kernel/configs/ados-common.config"
[ -z "$EXTRA_FRAGMENT" ] || FRAGMENTS="$FRAGMENTS $EXTRA_FRAGMENT"

"$SCRIPTS_CONFIG" --file "$CFG" --set-str BR2_TARGET_GENERIC_HOSTNAME "ados" --set-str BR2_TARGET_GENERIC_ISSUE "ADOS" --enable BR2_PACKAGE_OPENSSH --enable BR2_PACKAGE_NANO --enable BR2_PACKAGE_HTOP --enable BR2_PACKAGE_IPROUTE2 --enable BR2_PACKAGE_I2C_TOOLS --enable BR2_PACKAGE_LIBGPIOD --enable BR2_PACKAGE_LIBGPIOD_TOOLS --set-str BR2_ROOTFS_OVERLAY "$ROOT/board/raspberrypi/common/rootfs-overlay" --set-str BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES "$FRAGMENTS"
"$SCRIPTS_CONFIG" --file "$CFG" --disable BR2_LINUX_KERNEL_LATEST_VERSION --disable BR2_LINUX_KERNEL_CUSTOM_VERSION --disable BR2_LINUX_KERNEL_CUSTOM_TARBALL --enable BR2_LINUX_KERNEL_CUSTOM_GIT --set-str BR2_LINUX_KERNEL_CUSTOM_REPO_URL "https://github.com/raspberrypi/linux.git" --set-str BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION "$RPI_KERNEL_BRANCH"

make -C "$BR_DIR" O="$OUT" olddefconfig
make -C "$BR_DIR" O="$OUT" -j"$(nproc)"
IMG="$OUT/images/sdcard.img"
[ -f "$IMG" ] || { echo "ERROR: Build completed without sdcard.img" >&2; exit 1; }
NAME="ADOS-${TARGET}.img"
cp "$IMG" "$OUT_BASE/$NAME"
xz -T0 -f "$OUT_BASE/$NAME"
sha256sum "$OUT_BASE/$NAME.xz" > "$OUT_BASE/$NAME.xz.sha256"
echo "ADOS image ready: $OUT_BASE/$NAME.xz"
