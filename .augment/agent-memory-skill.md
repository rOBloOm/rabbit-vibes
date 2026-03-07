## Agent Memory Skill

Purpose:
- Use `documents/` as the durable memory system for this workspace.
- If the user says to look in `/documents`, read the memory files there before wider exploration.

Startup read order:
1. `documents/index.md`
2. `documents/project-memory.md`
3. `documents/mcp-capabilities.md`
4. `documents/jumpy-implementation-plan.md`

Behavior:
- Recover prior decisions, constraints, and verified capabilities from the memory files.
- Prefer stored memory facts over re-discovering the same information.
- If memory conflicts with the current codebase, verify and then update the memory.

What to record in `documents/`:
- User decisions
- Stable project facts
- Verified tool capabilities and limitations
- Workflow preferences that should persist across sessions

What not to record:
- Speculation
- Long logs
- Temporary dead ends unless they reveal a durable limitation

Maintenance rule:
- Keep entries concise, dated when useful, and easy to scan.
- Update the relevant memory file after a meaningful decision or verified finding.

