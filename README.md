# Bergraser

Ridge Racer 1 PS1 native recompilation MVP for PortMaster / RG40XX-H.
Implementation started; **not built as a full game or tested on hardware yet**.

Read AGENT_TASK.md and KNOWN_BLOCKERS.md. Work on prototype/rg40xx.

## Build and run
Provide private Japan SLPS-00001 files in one folder: PSX.EXE, data.iso,
optionally disc.cue and its referenced raw tracks. Upstream bin2iso.py converts
raw data-track BIN to 2048-byte ISO sectors. Keep original filenames for CUE tracks.

On an ARM64 Linux build host with gcc, Python 3, git, pkg-config and SDL2 development files:

```sh
RR_DATA_DIR=/private/ridge CC=gcc bash scripts/build-arm64.sh
bash scripts/probe-rg40xx.sh
bash scripts/deploy-rg40xx.sh
bash scripts/smoke-rg40xx.sh
bash scripts/fetch-rg40xx-log.sh
```

For cross-compilation use an aarch64 compiler/sysroot and target-only
PKG_CONFIG_LIBDIR. A target-compatible build host is preferred.
Upstream setup installs pinned Python disassembly dependencies; use a dedicated environment.

Copy your media privately to /userdata/roms/ports/bergraser/data/.
Launch Bergraser from KNULLI Ports. No game media is shipped.
Race performance and HZ=30 correctness still require a real device test.
