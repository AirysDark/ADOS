#!/usr/bin/env bash
set -euo pipefail
TARGET="${ADOS_TARGET:-unknown}"
mkdir -p "$TARGET_DIR/etc"
printf '%s\n' "$TARGET" > "$TARGET_DIR/etc/ados-target"
cat > "$TARGET_DIR/etc/os-release" <<EOF
NAME="ADOS"
ID=ados
PRETTY_NAME="ADOS ($TARGET)"
VERSION="0.1-dev"
VERSION_ID="0.1-dev"
HOME_URL="https://github.com/AirysDark/ADOS"
EOF
