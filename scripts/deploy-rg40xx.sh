#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOST="${RG40XX_USER:-root}@${RG40XX_HOST:-192.168.178.76}"
[ -f "$ROOT/dist/bergraser/ridge.aarch64" ] || { echo 'Run build-arm64.sh first' >&2; exit 2; }
ssh -o ConnectTimeout=5 "$HOST" 'mkdir -p /userdata/roms/ports/bergraser/data'
scp "$ROOT/dist/bergraser/ridge.aarch64" "$ROOT/dist/bergraser/LICENSE.upstream" "$HOST:/userdata/roms/ports/bergraser/"
scp "$ROOT/portmaster/Bergraser.sh" "$HOST:/userdata/roms/ports/Bergraser.sh"
ssh "$HOST" 'chmod +x /userdata/roms/ports/Bergraser.sh /userdata/roms/ports/bergraser/ridge.aarch64'
# No --delete, no media upload: preserve all user data.
