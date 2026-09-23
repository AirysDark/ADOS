#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

case "$TARGET" in
  rpi3-32|rpi3-64|rpi3bplus-32|rpi3bplus-64|rpi4-32|rpi4-64)
    ;;
  *)
    echo "Usage: $0 {rpi3-32|rpi3-64|rpi3bplus-32|rpi3bplus-64|rpi4-32|rpi4-64}" >&2
    exit 2
    ;;
esac

echo "ADOS build target: $TARGET"
echo "Buildroot integration is the next implementation stage."
exit 1
