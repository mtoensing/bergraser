# Bergraser — fast playable MVP on RG40XX-H

## Mission
Use the existing repository `mtoensing/bergraser`, branch `prototype/rg40xx`.
Get the existing Ridge Racer 1 PS1 native recompilation running on the real
Anbernic as quickly as practical. Execute the build/deploy/test loop; do not
stop at a plan, broad research or a successful headless compile.

First deliverable: a minimal PortMaster prototype that boots, reaches the
menu, accepts the built-in controls, plays audio and starts a playable race.
Measure actual gameplay immediately. Full-game polish and 60 FPS come later.

## Fixed test device — same as Sternenfuchs
- Anbernic RG40XX H; H700; 4x Cortex-A53 up to ~1.5 GHz; Mali-G31
- aarch64; 1 GB RAM; 640x480; KNULLI
- SSH: `root@192.168.178.76:22`; the device will be reachable for testing
- KNULLI default root password: `linux`
- If it fails: System Settings -> Security -> Root password
- SSH enabled at: System Settings -> Services -> SSH
- Persistent storage: `/userdata`
- PortMaster control file: `/userdata/system/.local/share/PortMaster/control.txt`
- Launcher: `/userdata/roms/ports/Bergraser.sh`
- Game directory: `/userdata/roms/ports/bergraser/`
- Logs: game folder `log.txt`; fetched logs under ignored `device-logs/`

Reuse working SSH keys and the Sternenfuchs build/deploy conventions.
Do not store actual passwords or private keys in git. The password above is
the documented firmware default, not a request to embed credentials in scripts.
If SSH is temporarily unavailable, continue independent build work and report
the exact connection failure; never claim a device test ran.

## Chosen starting point
- https://github.com/kazuyette/rr-decomp
- Runtime: `tools/m0/`
- Build instructions: https://github.com/kazuyette/rr-decomp/blob/main/tools/m0/README.md
- Reference workflow: https://github.com/mtoensing/sternenfuchs
- PortMaster: https://portmaster.games/porting.html
- Packaging: https://portmaster.games/packaging.html

Use rr-decomp's existing playable static recompilation. Do not wait for the
matching decompilation to finish and do not start a new decompilation.
Pin the actual upstream SHA in `scripts/versions.sh` and record it in SOURCES.md.
Read only upstream instructions, license and code relevant to the immediate build.

The existing runtime is documented as playable on Linux/Windows with SDL2,
controller input, music and effects. Its PS1 rasterizer runs on the CPU;
SDL/GLES presentation does not mean polygon drawing is GPU accelerated.
ARM64/device speed has not been verified here.

Alternative reference: https://github.com/kazuyette/rr-pc-port
This is a separate incomplete race slice. Do not switch to it silently or
replace original behavior with approximations to make the MVP look successful.

## Fast execution order
1. Clone/use bergraser and create `prototype/rg40xx` if absent. Inspect any
   existing work and preserve it. Pin upstream and read applicable AGENTS.md.
2. Check SSH and target architecture, libc and SDL2 availability. In parallel
   with device-independent work, locate the user's supported game files in
   the port directory or existing game storage. Do not download game media.
3. Use the user's Japanese PS1 release SLPS-00001: PSX.EXE and data track;
   CUE/audio tracks for music. Validate inputs. If absent, report the precise
   missing files, then continue toolchain and asset-free preparation.
4. Build the full native aarch64 runtime in an authorized environment with
   private access to those inputs. Prefer an existing ARM64 builder or a
   compatible cross-toolchain; reuse Ubuntu 22.04 userspace as a starting
   point. Public CI is not a prerequisite to the first device run.
5. Make only the build changes actually needed: compiler selection, x86-only
   flags, SDL2 discovery, target libc compatibility and generated-code issues.
   Start with an optimized build, not Debug. Do not redesign the runtime.
6. Use KNULLI/PortMaster's patched SDL2 and its working Mali/GLES backend.
   Preserve upstream CPU rasterization initially. Present the framebuffer
   through the existing SDL renderer/texture route; do not force desktop GL.
   Prefer native SDL gamepad input; no keyboard emulation unless input fails.
7. Add the smallest real launcher, logging and deploy/smoke/log-fetch scripts.
   Follow Sternenfuchs and PortMaster control.txt/get_controls/exit conventions.
   Check disc/audio paths: initial fixed paths inside the port directory are
   acceptable for this MVP, but no build-machine paths. Remove any upstream
   diagnostic run-duration limit from the interactive launcher.
8. Deploy only the port's own files. Never use deletion that removes user
   media, saves, settings, Sternenfuchs or other ports.
9. Run on the real display. Pause EmulationStation only for the SSH smoke
   test and restore it afterward; reuse Sternenfuchs' approach. Fetch logs.
10. Fix the smallest observed build/startup/input/audio blocker and repeat.
    Do not stop merely because one attempt failed.
11. Verify title/menu, built-in controller, sound and a real race. Use available
    scripted input for reproducibility and screenshots where useful. Clearly
    separate automatic checks from user-only/manual checks.
12. Run at least 60 seconds of representative racing, preferably a complete
    race. Report measured FPS/frame times, audio behavior, CPU use and game
    timer versus wall-clock. Do not benchmark a title screen as gameplay.
13. Commit the reproducible changes and document exact launch/build commands,
    required game files and observed limitations. Provide a local sideload
    package when distribution terms permit. Only then add useful asset-free
    CI and packaging polish; neither should delay the first working race.

## MVP acceptance and performance gate
Priorities: boot -> menu -> controller -> audio -> playable race -> original speed.
Display at 640x480, 4:3, preserving original internal resolution and visuals.

The initial timing target is the runtime's documented original 30 FPS racing
behavior; verify its timing on hardware rather than assuming HZ=30 is correct.
A playable but slow race is a useful prototype result, clearly labelled
PERFORMANCE FAIL; it is not a finished successful port.

Do not change physics, timers, audio speed, simulation rate, skip frames or
discard visual correctness to reach a number. 60 FPS presentation/interpolation
is a later enhancement, not an MVP requirement.

If speed is insufficient:
- Obtain a short on-device profile separating translated game code, GTE,
  rasterizer, audio and presentation.
- Apply small, measured fixes if readily available, then remeasure.
- If a new GPU polygon renderer or deep architecture work is required, record
  the measured bottleneck and a concrete follow-up recommendation. Finish the
  usable prototype handoff instead of expanding this task into a renderer rewrite.
- Never conclude the device is too weak from a Debug build or unmeasured guess.

## Scope limits
- No Vulkan, WestonPack, replacement graphics drivers, firmware changes,
  overclocking, broad refactoring or speculative compatibility layers.
- Do not bundle/replace SDL2, libc, libstdc++ or firmware graphics libraries.
- No 60 FPS project, widescreen, HD textures, release marketing or PortMaster PR.
- Respect upstream license notices. Do not publish game data or generated game
  code. Keep PSX.EXE, disc images, extracted assets, generated game.c/disassembly,
  private logs and builds containing embedded game content out of public git/CI.
- A full build needs private game-derived inputs; an asset-free CI pass is not
  evidence that gameplay works.
- Scripts named here are requirements to implement, not files already supplied.
- Author commits as the repository owner using the configured GitHub noreply
  identity, with no AI-author or AI coauthor attribution.
- Record actual failures and fixes in KNOWN_BLOCKERS.md; mark assumptions clearly.

## Concise status
Build: PASS/FAIL/NOT RUN — exact result
Deploy: PASS/FAIL/NOT RUN — exact result
Device: PASS/FAIL/NOT RUN — furthest verified screen/race
Performance: measured race FPS and timing, or NOT TESTED
Changed: files/commit
Next: one concrete action

Keep working until the playable MVP is delivered or a concrete external blocker
prevents further progress. Do not claim success from build output alone.
