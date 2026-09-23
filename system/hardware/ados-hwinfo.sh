#!/bin/sh
# ADOS early hardware identification helper.

model="unknown"
revision="unknown"

if [ -r /proc/device-tree/model ]; then
    model="$(tr -d '\000' < /proc/device-tree/model)"
fi

if [ -r /proc/cpuinfo ]; then
    revision="$(awk -F ': ' '/^Revision/ {print $2; exit}' /proc/cpuinfo)"
    [ -n "$revision" ] || revision="unknown"
fi

arch="$(uname -m 2>/dev/null || echo unknown)"

printf 'ADOS hardware detection\n'
printf 'Model: %s\n' "$model"
printf 'Revision: %s\n' "$revision"
printf 'Architecture: %s\n' "$arch"
