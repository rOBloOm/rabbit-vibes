## Project Memory

### User workflow preference
- The `documents/` folder is the durable memory area for future sessions.
- If the user says to look in `/documents`, read these memory files first.

### Project identity
- Project/workspace: `jumpy`
- Current repository root: `C:/dev/jumpy`
- Current implementation plan file: `documents/jumpy-implementation-plan.md`

### Current project decisions
- Game type: 2D platformer
- Core objective: reach the top of the level
- Engine family: Godot
- Engine variant: Godot 4.x
- Primary scripting language: GDScript
- Planning artifact location currently used: `documents/`
- Current target resolution: `1280x720`
- Current input scheme: `A/D` move left/right, `Space` or `W` jump, `E` interact
- Additional session controls: `Esc`/`P` pause, `Enter` confirm/start, `R` restart from menu/win screens

### Environment facts
- Godot install verified at `C:/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64.exe`
- Verified Godot version: `4.6.1.stable.mono.official.14d19694e`
- Verified .NET SDK version: `10.0.100`
- `C:/dev/jumpy` is now a valid root Godot project
- Root bootstrap now uses `project.godot`, scene files, and GDScript files under `scripts/*.gd`
- Old C# project files (`jumpy.csproj`, `jumpy.slnx`, `scripts/*.cs`) were removed on 2026-03-07 during the web-export migration
- Local Git repository initialized on branch `main` on 2026-03-07
- GitHub Pages deployment scaffolding now exists via `.github/workflows/deploy-pages.yml`, `export_presets.cfg`, and `.gitignore`
- The Pages workflow exports a Godot Web build using a non-.NET Linux Godot binary in CI because local Mono/.NET Godot builds cannot export Web

### MCP configuration facts
- Workspace MCP config file: `.augment/settings.json`
- Godot MCP is configured to launch `node C:/dev/godot-mcp/build/index.js`
- `GODOT_PATH` was set to the verified Godot executable path
- `DEBUG` was removed from MCP env because it can interfere with MCP stdio/protocol behavior
- The in-session Augment Godot tool was stale earlier, but later root project listing and scene creation worked

### Current temporary test assets
- The disposable MCP test project files under `mcp_sandbox/` were removed; empty directories may remain because the safe delete tool does not remove folders
- Direct MCP probe script exists at `mcp-probe.mjs`

### Current prototype state
- `Main.tscn` is now a wider meadow slice with hills, a larger ground plane, several platforms, trees, bushes, and buried carrot patches
- `Player.tscn` is a real reusable player scene with a Camera2D child
- `Player.cs` currently supports tuned left/right movement, gravity, variable jump height, and sharper jump-cut behavior
- `Player.cs` now also supports one double jump and a jump sound effect
- The player now uses a stylized bunny visual built from real scene nodes in `scenes/BunnyVisual.tscn`
- Bunny motion is procedurally animated for idle, run/hop, and jump/fall states
- The bunny also has a digging state/animation triggered by `E` near carrot patches
- Reusable meadow scenes now exist at `scenes/Tree.tscn`, `scenes/Bush.tscn`, and `scenes/CarrotPatch.tscn`
- Ambient meadow scenes now exist at `scenes/WindAmbient.tscn` and `scenes/BirdFlock.tscn`
- The main scene now includes a carrot counter HUD
- Procedurally generated audio assets exist at `assets/audio/meadow_theme.wav` and `assets/audio/carrot_munch.wav`
- Procedurally generated jump audio exists at `assets/audio/rabbit_jump.wav`
- Audio is loaded at runtime via `AudioStreamWav.LoadFromFile(...)` instead of scene-time audio imports
- The current loop now includes a title overlay, pause overlay, and win overlay managed by `Main.cs`
- All carrots must be collected to unlock the burrow goal in `scenes/GoalBurrow.tscn`
- Hazards/enemies now exist via `scenes/ThornPatch.tscn` and `scenes/FoxEnemy.tscn`; touching them respawns the player at the start

