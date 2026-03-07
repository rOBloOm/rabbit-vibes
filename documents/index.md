## Documents Memory Index

Use this folder as the durable memory area for this workspace.

Read in this order at the start of a new session:
1. `.augment/agent-memory-skill.md`
2. `documents/index.md`
3. `documents/project-memory.md`
4. `documents/mcp-capabilities.md`
5. `documents/jumpy-implementation-plan.md`

Files:
- `.augment/agent-memory-skill.md`: canonical agent-facing instruction for using `documents/` as durable memory
- `project-memory.md`: decisions, environment facts, and current working agreements
- `mcp-capabilities.md`: proven tool behavior, especially Godot MCP behavior
- `jumpy-implementation-plan.md`: the main project plan and decision log

Update rules:
- Record stable decisions, not noisy transient thoughts
- Prefer dated bullets for notable discoveries
- Update capability status when a tool is actually tested
- Keep this folder concise and easy to scan

