## Godot MCP Capability Memory

### Verified by direct MCP server testing
These were tested directly against `C:/dev/godot-mcp/build/index.js` with `GODOT_PATH` set.

### Confirmed working
- `launch_editor`
- `get_godot_version`
- `list_projects`
- `get_project_info`
- `create_scene`
- `add_node`
- `save_scene`
- `run_project`
- `get_debug_output`
- `stop_project`

### What this means in practice
- Open a Godot project in the editor
- Run a Godot project
- Stop a running Godot project
- Read runtime/debug output from a launched project
- Detect Godot projects in a directory
- Inspect a project and report basic structure/version info
- Create a new scene
- Add nodes to a scene
- Save scene changes

### Observed behavior
- The MCP server starts successfully over stdio
- It correctly recognizes the configured Godot path
- A direct end-to-end `launch_editor` MCP test created a new Godot editor process for `mcp_sandbox/`
- The built-in in-chat `launch_editor_godot` wrapper later returned success for the root `jumpy` project without actually creating a Godot process; verify editor launch with a process check when using the wrapper
- It can discover a disposable Godot project in `mcp_sandbox/`
- It can create `scenes/Main.tscn`, add nodes, save, run, and stop the project
- Runtime debug output included normal engine startup and Vulkan device info

### Partially tested or questionable
- `load_sprite` failed for both SVG and PNG test assets with `No loader found for resource`
- `get_uid` reported no UID file for the created scene
- `update_project_uids` reported success but appeared to search an invalid path and found 0 scenes

### Not fully exercised yet
- `export_mesh_library`

### Confidence levels
High confidence:
- editor launch
- project launch/stop
- scene creation
- adding nodes
- saving scenes
- project discovery/info

Low confidence:
- sprite loading/import handling
- UID-related operations

### Practical guidance
- Trust MCP first for scene creation, adding nodes, saving scenes, and run/stop/debug flows
- Be cautious with sprite loading and UID-related operations until re-tested or fixed

