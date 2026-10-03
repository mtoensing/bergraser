#!/usr/bin/env bash
set -euo pipefail
HOST="${RG40XX_USER:-root}@${RG40XX_HOST:-192.168.178.76}"
ssh -o ConnectTimeout=5 "$HOST" 'uname -a; getconf GNU_LIBC_VERSION; ls -l /usr/lib/libSDL2* /userdata/system/.local/share/PortMaster/control.txt; ls -l /userdata/roms/ports/bergraser/data 2>/dev/null || true'
