# claude-forge

My Claude Code customisations - skills, agents, hooks, settings - kept under version control.

## Structure

```text
claude-forge/
├── skills/         # slash skills, one folder per skill
├── statusline/     # cross-platform Claude Code status line
├── .plans/         # planning docs for upcoming work
├── CLAUDE.md       # repo guide for Claude
├── README.md       # you are here
└── LICENSE         # Apache-2.0
```

Each top-level folder has its own `README.md` acting as the index for that
slice (see [skills/README.md](skills/README.md) for the skills index and
[statusline/README.md](statusline/README.md) for the status line).

New surfaces (`agents/`, `hooks/`, `settings/`, `mcp/`) get added when there
is something to put in them - same pattern: one folder, one index README, one
sub-folder or file per item.

## Install

Installer is not built yet (see [.plans/](.plans/) for what is coming). For
now, copy a skill manually:

```bash
# Linux / Mac
cp -r skills/panel-review ~/.claude/skills/
```

```powershell
# Windows
Copy-Item -Recurse skills\panel-review $env:USERPROFILE\.claude\skills\
```

Each skill may include a `.skillignore` listing files that are
dev-facing only (e.g. `AGENT.md`, `README.md`) and not needed at
runtime. The eventual installer will honour it; for manual copies you
can delete those files from the destination afterwards.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
