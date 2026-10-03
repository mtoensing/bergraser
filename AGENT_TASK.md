# Bergraser — implementation task

## Goal
Use the existing repository `mtoensing/bergraser` and bring Ridge Racer 1 (PS1, Japan SLPS-00001) to native aarch64 PortMaster on a real Anbernic RG40XX-H. Start from the static recompilation in kazuyette/rr-decomp, not a claim of a finished C decompilation.

## Fixed inputs
- Owner/repository: mtoensing/bergraser
- Branch: prototype/rg40xx
- Target: RG40XX-H; H700; aarch64; 1 GB RAM; 640x480; KNULLI
- Previous Sternenfuchs test endpoint: root@192.168.178.76:22. Verify availability before deployment; do not assume it is current.
- Persistent storage: /userdata
- Port directory: /userdata/roms/ports/bergraser
- Enable SSH in System Settings -> Services -> SSH. Obtain credentials from the user/device settings; never commit credentials.

## Sources and known state (research 2026-10-03)
- https://github.com/kazuyette/rr-decomp
- https://github.com/kazuyette/rr-decomp/blob/main/tools/m0/README.md
- https://github.com/kazuyette/rr-pc-port
- https://portmaster.games/porting.html
- https://portmaster.games/packaging.html
- Reference task: https://github.com/mtoensing/sternenfuchs/blob/main/AGENT_TASK.md

rr-decomp reports 219/949 functions and 5.6% of instructions recovered as real C. Its separate static recompilation translates MIPS into C and models required PS1 hardware. The runtime is documented as playable on Linux/Windows with SDL2, input and audio. It uses a software rasterizer; hardware rendering remains unfinished. ARM64 and this handheld are unverified.

rr-pc-port is a separate portable-C playable race slice, not proof of complete game coverage. Its README has an older decomp progress number; use rr-decomp's current progress tool instead. Prefer rr-decomp for original game behavior unless observed blockers justify switching.

## Execute
1. Inspect upstream AGENTS.md if present, LICENSE, tools/m0/build.py, runtime README and actual code. Resolve license/distribution requirements before importing source or publishing binaries; do not assume an OSI license.
2. Pin the selected upstream commit in scripts/versions.sh. Record exact SHA and source URL in SOURCES.md. Do not invent a SHA or update it during bring-up.
3. Add AGENTS.md with repository-owner commit attribution, README.md with truthful prototype status, SOURCES.md, .gitignore and reproducible bootstrap scripts.
4. Keep game assets local. Support the user's own SLPS-00001 disc, PSX.EXE, data track and optional CUE/audio tracks. Validate inputs with actionable errors.
5. Implement scripts/build-arm64.sh and .github/workflows/build-arm64.yml. Prefer a native ARM64 runner with a target-compatible userspace (Ubuntu 22.04 container as the Sternenfuchs starting point). Verify glibc and library compatibility against the actual firmware.
6. Adapt tools/m0/build.py for aarch64 compiler selection, SDL2 discovery and reproducible generation. Audit x86 flags, alignment, pointer/integer assumptions, endianness and generated-code compilation. Do not use x86 emulation.
7. Use target-provided patched SDL2 for video, audio and controllers. Test KMS/DRM or the firmware's supported SDL2 backend without a desktop. Distinguish CPU rasterization from GPU-backed framebuffer presentation.
8. Make paths relocatable. Audit generated absolute disc/audio paths; resolve user data at runtime. No developer-machine paths or gameplay duration timeout in the final launcher.
9. Add a PortMaster launcher with control.txt integration, working directory, log path, clean exit, and controller mappings only if native SDL gamepad input fails.
10. Add scripts/setup-ssh.sh, deploy-rg40xx.sh, smoke-rg40xx.sh and fetch-rg40xx-log.sh. Make them real executable implementations before referring to them as supplied. Deploy only the port's own files and preserve user data.
11. Make the ARM64 workflow pass, download its artifact, deploy, run smoke tests, fetch logs and fix the smallest actual build/runtime blocker.
12. Launch from KNULLI's Ports menu. Verify boot, title/menu, controller, audio, full race and clean exit.
13. Profile representative races on device: separate game/recompiled code, GTE, CPU rasterizer, SPU/audio and presentation costs. Record frame times, peak memory, audio underruns and wall-clock versus race-clock time.
14. Optimize only measured bottlenecks. If CPU rasterization is insufficient, evaluate a faithful GLES renderer while preserving PS1 ordering, affine texture behavior, CLUTs, masking and transparency. Preserve a reference software path for comparison.
15. Package a sideload artifact with only the launcher and game folder at its root. Prepare PortMaster submission metadata only after real gameplay works and distribution requirements are resolved.

## Priorities and acceptance
1. Boot
2. Menu
3. Controller
4. Audio (music and effects)
5. One complete playable race
6. Sustained original game speed, initially the documented 30 FPS race target

Correct gameplay speed is mandatory. Compare at least 60 seconds of wall-clock and race-clock time. Never reach a frame-rate target by accelerating physics/timers/audio or by slowing simulation, skipping frames or dropping visual correctness.

Treat 60 FPS presentation/gameplay as a separate, researched enhancement. Increasing HZ alone is not a verified 60 FPS fix. Preserve original internal rendering initially and scale to the 640x480 display with correct 4:3 aspect ratio.

## Constraints
- No Vulkan, WestonPack, replacement drivers or unrelated refactoring as the initial approach.
- Do not bundle/replace libc, libstdc++, SDL2 or firmware graphics libraries without a proven specific blocker and documented resolution.
- Do not commit disc images, PSX.EXE, extracted assets, assembly/disassembly generated from the game, generated game.c, save states or builds containing embedded copyrighted game content.
- Ensure CI does not require uploading game data or generated game code to public services. An asset-free CI pass is not proof that the full game builds; document which validation ran locally with private inputs.
- Never report a headless build as a working playable port or skipped asset tests as gameplay validation.
- No PortMaster PR before hardware gameplay and packaging work.
- Never claim code, scripts, workflows or performance are already verified when they have not run.

## If blocked
Read SOURCES.md and inspect only source relevant to the observed error. Document a concrete blocker and next experiment in KNOWN_BLOCKERS.md. Use rr-pc-port only after comparing behavior coverage and portability; do not silently replace original gameplay with approximations.

## Keep status replies tiny
Build: PASS/FAIL/NOT RUN — one line
Deploy: PASS/FAIL/NOT RUN — one line
Device: PASS/FAIL/NOT RUN — one line
Changed: files/commit
Next: single next action

