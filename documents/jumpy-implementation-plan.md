## Jumpy - Decisions and Implementation Plan

### Project Overview
- Working title: `jumpy`
- Genre: 2D platformer
- Core objective: reach the top of the level
- Initial scope: small, playable vertical platformer prototype first

### Decision Log
#### Confirmed Decisions
- Engine family: Godot
- Engine variant: Godot 4.x
- Primary scripting language: GDScript
- Godot version: `4.6.1.stable.mono.official.14d19694e`
- .NET SDK version: `10.0.100`
- Target resolution: `1280x720`
- Current input scheme: `A/D` move left/right, `Space` or `W` jump, `E` interact
- Collaboration model: Augment Agent handles planning, code, and project file edits; user handles editor/runtime validation as needed
- Planning artifact location: `documents/`
- Augment settings file created at `.augment/settings.json` for upcoming MCP configuration

#### Current Assumptions
- The project will begin with placeholder art and simple level geometry
- The first milestone is a playable prototype, not final polish

#### Open Decisions
- Initial target platform(s): Web plus desktop exports
- Visual direction: minimalist shapes vs. pixel art vs. custom art later

### Working Plan
#### Phase 0 - Environment Setup
1. Create a blank Godot .NET project in this repository ✅
2. Confirm installed Godot version and .NET SDK version ✅
3. Add Godot MCP configuration to `.augment/settings.json` ✅
4. Validate that the Godot MCP server is connected and usable ✅
5. Commit to initial target resolution and input scheme ✅

#### Phase 1 - Core Prototype
Goal: create a vertical slice that is playable from start to finish

Planned features:
- Player scene with left/right movement and jumping
- Gravity and collision handling
- Camera follow system
- One vertical test level
- Goal object at the top of the level
- Basic restart flow on fall or failure

Deliverable:
- A minimal game where the player can climb and reach the top

#### Phase 2 - Platformer Feel
Goal: make movement satisfying and responsive

Planned features:
- Tuned acceleration and air control
- Adjustable jump height / jump tuning
- Coyote time
- Jump buffering
- Fall speed tuning
- Camera smoothing review

Deliverable:
- Movement that feels intentionally platformer-like rather than purely default physics

#### Phase 3 - Gameplay Expansion
Goal: add challenge and progression

Planned features:
- Static and moving platforms
- Hazards (for example spikes)
- Checkpoints
- Level reset / respawn behavior
- Basic HUD or status UI if needed

Deliverable:
- A more game-like climb with failure, recovery, and progress markers

#### Phase 4 - Content and Polish
Goal: make the prototype presentable

Planned features:
- Visual cleanup and consistent art direction
- Sound effects and music
- Start screen / win screen
- Juice and feedback (particles, squash, screen shake, etc. as appropriate)
- Export and playtest fixes

Deliverable:
- A polished small game build

### Proposed Technical Structure
#### Likely folders
- `scenes/`
- `scripts/`
- `assets/`
- `ui/`
- `levels/`
- `documents/`

#### Likely gameplay scenes/scripts
- `Player`
- `Main` or `Game`
- `Level_01`
- `Goal`
- `Hazard`
- `Checkpoint`
- `HUD`

### Roles and Workflow
#### What Augment Agent will do
- Maintain this plan and decision log
- Write GDScript gameplay scripts
- Create and edit scene/config files where possible
- Propose and implement incremental milestones
- Run safe codebase checks where available

#### What the user will do
- Open the Godot .NET project locally
- Run the game in the editor
- Report runtime behavior and feel
- Perform any small GUI-only steps if needed

### Immediate Next Steps
1. Commit to the initial target resolution and input scheme
2. Turn Phase 1 into a concrete task breakdown
3. Create the player scene and movement script
4. Build a first vertical test level
5. Run and tune the prototype loop

### Change Log
- Created initial implementation plan and decision log on 2026-03-07
- Updated plan to note `.augment/settings.json` creation and MCP setup-in-progress on 2026-03-07
- Moved implementation plan from `docmuents/` to `documents/` on 2026-03-07
- Bootstrapped the root Godot .NET project and resolved exact Godot/.NET versions on 2026-03-07
- Added the first playable movement slice with real scenes, camera, platforms, and A/D + jump controls on 2026-03-07
- Replaced the placeholder block player with a stylized animated bunny character on 2026-03-07
- Expanded the test level into a meadow slice and added buried carrot digging/collection on 2026-03-07
- Added generated meadow music and carrot munch audio using runtime WAV loading on 2026-03-07
- Added double jump, jump SFX, carrot HUD, and ambient wind/bird/particle polish on 2026-03-07
- Added a gated goal, hazards/enemy, and title/pause/win loop flow on 2026-03-07
- Migrated the project from C#/.NET to pure GDScript and removed the old C# project files on 2026-03-07
- Added GitHub Pages deployment scaffolding, a Godot `.gitignore`, and initialized a local Git repository on 2026-03-07

