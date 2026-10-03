#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/device-logs"
HOST="${RG40XX_USER:-root}@${RG40XX_HOST:-192.168.178.76}"
scp "$HOST:/userdata/roms/ports/bergraser/*.log" "$ROOT/device-logs/"
