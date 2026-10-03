#!/usr/bin/env bash
set -euo pipefail
if [[ -d /opt/system/Tools/PortMaster ]]; then
  controlfolder=/opt/system/Tools/PortMaster
elif [[ -d /opt/tools/PortMaster ]]; then
  controlfolder=/opt/tools/PortMaster
else
  controlfolder=/userdata/system/.local/share/PortMaster
fi
source "$controlfolder/control.txt"
get_controls
GAMEDIR="$(cd -- "$(dirname -- "$0")" && pwd)/bergraser"
cd "$GAMEDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export HZ="${HZ:-30}"
for item in data/PSX.EXE data/data.iso ridge.aarch64; do
  [ -f "$item" ] || { echo "Missing: $item" >>log.txt; exit 2; }
done
chmod +x ridge.aarch64
"$GPTOKEYB" ridge.aarch64 &
KEY_PID=$!
trap 'kill "$KEY_PID" 2>/dev/null || true' EXIT
# Upstream alarm(0) disables its diagnostic run-duration limit.
./ridge.aarch64 0 data/PSX.EXE >log.txt 2>&1
