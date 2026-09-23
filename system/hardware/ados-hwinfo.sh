#!/bin/sh
# ADOS early hardware identification helper.
model="unknown"; revision="unknown"; hardware="unknown"
[ ! -r /proc/device-tree/model ] || model="$(tr -d '\000' < /proc/device-tree/model)"
if [ -r /proc/cpuinfo ]; then
    revision="$(awk -F ': ' '/^Revision/ {print $2; exit}' /proc/cpuinfo)"
    hardware="$(awk -F ': ' '/^Hardware/ {print $2; exit}' /proc/cpuinfo)"
fi
arch="$(uname -m 2>/dev/null || echo unknown)"
printf 'ADOS hardware detection\n'
printf 'Board model: %s\n' "${model:-unknown}"
printf 'Board revision: %s\n' "${revision:-unknown}"
printf 'Hardware/SoC: %s\n' "${hardware:-unknown}"
printf 'Architecture: %s\n' "$arch"
printf 'Kernel: %s\n' "$(uname -r 2>/dev/null || echo unknown)"
