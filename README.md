# claude-forge

My Claude Code customisations - skills, agents, hooks, settings - kept under version control.

## Structure

```text
claude-forge/
├── skills/         # slash skills, one folder per skill (install globally)
├── .claude/skills/ # project-scoped repo-tooling skills (loaded only here)
├── statusline/     # cross-platform Claude Code status line
├── bin/            # install scripts (PowerShell + bash)
├── .plans/         # planning docs for upcoming work
├── GUIDE.md        # getting the most out of Claude Code
├── CLAUDE.md       # repo guide for Claude
├── README.md       # you are here
└── LICENSE         # Apache-2.0
```

New here? Start with **[GUIDE.md](GUIDE.md)** — a short, opinionated guide
to getting the most out of Claude Code (what aids the human vs. what aids
the agent).

Each top-level folder has its own `README.md` acting as the index for that
slice (see [skills/README.md](skills/README.md) for the skills index,
[statusline/README.md](statusline/README.md) for the status line, and
[bin/README.md](bin/README.md) for the installer).

New surfaces (`agents/`, `hooks/`, `settings/`, `mcp/`) get added when there
is something to put in them - same pattern: one folder, one index README, one
sub-folder or file per item.

## Install

Use the installer in [`bin/`](bin/README.md). It copies a skill into
`~/.claude/skills/` and honours that skill's `.skillignore` (dev-facing files
like `AGENT.md` / `README.md` are left out of the runtime copy).

```powershell
# Windows
bin\install.ps1 panel-review        # one skill
bin\install.ps1 -All                # everything
bin\install.ps1 -List               # what's available
bin\install.ps1 panel-review -DryRun  # preview, write nothing
```

```bash
# Linux / Mac
bin/install.sh panel-review         # one skill
bin/install.sh --all                # everything
bin/install.sh --list               # what's available
bin/install.sh panel-review --dry-run # preview, write nothing
```

An already-installed skill is left alone unless you pass `-Force` / `--force`.
Full flag reference: [bin/README.md](bin/README.md). Manual copy still works if
you'd rather — see that page for the one-liner.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
