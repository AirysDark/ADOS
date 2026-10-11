#!/usr/bin/env bash
set -euo pipefail

BUILDROOT_VERSION="2025.02.18"
RPI_KERNEL_REPO="https://github.com/AirysDark/linux.git"
RPI_KERNEL_BRANCH="rpi-6.12.y"
RPI_KERNEL_COMMIT="43c132e8863c3bff3647033b6a7d2bf87b15501c"
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
FRAGMENTS="$ROOT/kernel/configs/ados-common.config"
[ -z "$EXTRA_FRAGMENT" ] || FRAGMENTS="$FRAGMENTS $EXTRA_FRAGMENT"

# Buildroot has no Linux-style support/kconfig/scripts/config helper.
# Append ADOS selections to the generated defconfig, then let olddefconfig
# resolve dependencies and normalize the final configuration.
cat >> "$CFG" <<EOF
BR2_TARGET_GENERIC_HOSTNAME="ados"
BR2_TARGET_GENERIC_ISSUE="ADOS"
BR2_PACKAGE_OPENSSH=y
BR2_PACKAGE_DBUS=y
BR2_PACKAGE_BLUEZ5_UTILS=y
# bluetoothctl is an optional BlueZ CLI component in Buildroot.
BR2_PACKAGE_BLUEZ5_UTILS_CLIENT=y
BR2_PACKAGE_HOSTAPD=y
BR2_PACKAGE_WPA_SUPPLICANT=y
BR2_PACKAGE_IW=y
BR2_PACKAGE_PYTHON3=y
BR2_PACKAGE_NANO=y
BR2_PACKAGE_HTOP=y
BR2_PACKAGE_IPROUTE2=y
BR2_PACKAGE_I2C_TOOLS=y
BR2_PACKAGE_LIBGPIOD=y
BR2_PACKAGE_LIBGPIOD_TOOLS=y
BR2_PACKAGE_FILE=y
BR2_PACKAGE_BINUTILS=y
BR2_PACKAGE_PYTHON_DBUS_NEXT=y
BR2_ROOTFS_OVERLAY="$ROOT/board/raspberrypi/common/rootfs-overlay"
BR2_ROOTFS_POST_BUILD_SCRIPT="$ROOT/board/raspberrypi/common/post-build.sh"
BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES="$FRAGMENTS"
# Keep the Buildroot toolchain UAPI headers aligned with the ADOS 6.12 kernel.
# BR2_KERNEL_HEADERS_6_6 is not set
BR2_KERNEL_HEADERS_6_12=y
# Raspberry Pi defconfigs force hashes for upstream source archives.
# Our custom Git kernel is pinned to an immutable commit but has no
# Buildroot-generated git4 archive hash yet; keep normal hash checks.
# BR2_DOWNLOAD_FORCE_CHECK_HASHES is not set
# BR2_LINUX_KERNEL_LATEST_VERSION is not set
# BR2_LINUX_KERNEL_CUSTOM_VERSION is not set
# BR2_LINUX_KERNEL_CUSTOM_TARBALL is not set
BR2_LINUX_KERNEL_CUSTOM_GIT=y
BR2_LINUX_KERNEL_CUSTOM_REPO_URL="$RPI_KERNEL_REPO"
BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION="$RPI_KERNEL_COMMIT"
EOF

make -C "$BR_DIR" O="$OUT" olddefconfig
export ADOS_TARGET="$TARGET"
export ADOS_ROOT="$ROOT"
make -C "$BR_DIR" O="$OUT" -j"$(nproc)"
IMG="$OUT/images/sdcard.img"
[ -f "$IMG" ] || { echo "ERROR: Build completed without sdcard.img" >&2; exit 1; }
NAME="ADOS-${TARGET}.img"
cp "$IMG" "$OUT_BASE/$NAME"
xz -T0 -f "$OUT_BASE/$NAME"
sha256sum "$OUT_BASE/$NAME.xz" > "$OUT_BASE/$NAME.xz.sha256"
{
  echo "ADOS target: $TARGET"
  echo "Buildroot: $BUILDROOT_VERSION"
  echo "Kernel source: AirysDark/linux $RPI_KERNEL_BRANCH"
  echo "Kernel repository: $RPI_KERNEL_REPO"
  echo "Kernel commit: $RPI_KERNEL_COMMIT"
  echo "Base defconfig: $BASE_DEFCONFIG"
  echo "Kernel fragments: $FRAGMENTS"
  echo "Portable source: portable/ (embedded automatically)"
  echo "Portable commit: $(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
} > "$OUT_BASE/ADOS-${TARGET}.build-info.txt"
echo "ADOS image ready: $OUT_BASE/$NAME.xz"
