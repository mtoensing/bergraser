#!/usr/bin/env bash
set -euo pipefail
HOST="${RG40XX_USER:-root}@${RG40XX_HOST:-192.168.178.76}"
ssh -o ConnectTimeout=5 "$HOST" bash -s <<'REMOTE'
set -eu
cd /userdata/roms/ports/bergraser
ldd ./ridge.aarch64
[ -f data/PSX.EXE ] && [ -f data/data.iso ]
ES_PID="$(pgrep -f 'exit-on-reboot-required' | head -1)"
trap '[ -z "$ES_PID" ] || kill -CONT "$ES_PID" 2>/dev/null || true' EXIT
[ -z "$ES_PID" ] || kill -STOP "$ES_PID"
export SDL_VIDEODRIVER=mali XDG_RUNTIME_DIR=/var/run HZ=30
# No dummy audio: test the real device; this is boot smoke, not a race benchmark.
./ridge.aarch64 20 data/PSX.EXE >smoke.log 2>&1
cat smoke.log
REMOTE
