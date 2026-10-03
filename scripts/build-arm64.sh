#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/versions.sh"
DATA="${RR_DATA_DIR:?Set RR_DATA_DIR to your private SLPS-00001 files (PSX.EXE, data.iso, optional disc.cue)}"
DATA="$(cd "$DATA" && pwd)"
for item in PSX.EXE data.iso; do
  [ -f "$DATA/$item" ] || { echo "Missing: $DATA/$item" >&2; exit 2; }
done
PYTHON="${PYTHON:-python3}"
CC="${CC:-aarch64-linux-gnu-gcc}"
PKG_CONFIG="${PKG_CONFIG:-pkg-config}"
for tool in git "$PYTHON" "$CC" "$PKG_CONFIG"; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 2; }
done
case "$("$CC" -dumpmachine)" in aarch64*) ;; *) echo 'Compiler must target aarch64' >&2; exit 2;; esac
"$PKG_CONFIG" --exists sdl2 || { echo 'Target SDL2 development files missing. Set PKG_CONFIG_LIBDIR to the ARM64 sysroot.' >&2; exit 2; }
mkdir -p "$ROOT/work"
SRC="$ROOT/work/rr-decomp"
[ -d "$SRC/.git" ] || git clone "$RR_URL" "$SRC"
git -C "$SRC" checkout --detach "$RR_REV"
"$PYTHON" - "$DATA/PSX.EXE" <<'CHECK'
import hashlib,sys
p=sys.argv[1]
expected='31ec5d3616a0fdb456da27a984fc5b92259ff1f6'
if hashlib.sha1(open(p,'rb').read()).hexdigest()!=expected:
    raise SystemExit('Unsupported PSX.EXE: expected original Japan SLPS-00001')
CHECK
cp "$DATA/PSX.EXE" "$SRC/PSX.EXE"
(cd "$SRC" && "$PYTHON" tools/setup.py)
args=("$DATA/PSX.EXE" --iso "$DATA/data.iso" --cc "$CC")
[ ! -f "$DATA/disc.cue" ] || args+=(--cue "$DATA/disc.cue")
"$PYTHON" "$SRC/tools/m0/build.py" "${args[@]}"
# Rebase generated disc paths to the fixed MVP device data directory.
"$PYTHON" - "$SRC/build/m0/cdfiles.c" "$DATA" <<'REBASE'
from pathlib import Path
import sys
p=Path(sys.argv[1]); old=sys.argv[2].replace('\\','\\\\')
p.write_text(p.read_text().replace(old,'/userdata/roms/ports/bergraser/data'))
REBASE
read -r -a SDL_FLAGS <<< "$("$PKG_CONFIG" --cflags --libs sdl2)"
OUT="$ROOT/dist/bergraser"
mkdir -p "$OUT"
# CC can be a wrapper to supply --sysroot. Target pkg-config must never use host SDL.
"$CC" -O2 -fcommon -DWITH_SDL -I "$SRC/tools/m0" \
 "$SRC"/tools/m0/{main,hw,gpu,gte,video,audio,spu,mods}.c \
 "$SRC"/build/m0/{game,table,cdfiles,ram}.c \
 "${SDL_FLAGS[@]}" -o "$OUT/ridge.aarch64"
cp "$SRC/LICENSE" "$OUT/LICENSE.upstream"
cp "$ROOT/portmaster/Bergraser.sh" "$ROOT/dist/Bergraser.sh"
echo "Built $OUT/ridge.aarch64; game media must stay private."
