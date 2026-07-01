# Skills

Claude Code slash skills. Each skill is its own folder with a `SKILL.md` and
any supporting assets (personas, templates, etc).

## Index

| Skill                         | What it does                                       |
| ----------------------------- | -------------------------------------------------- |
| [cafe](cafe/)                   | Morning brief, ordered like coffee.                   |
| [feature-scope](feature-scope/) | Map out & size a small feature before the build plan. |
| [handoff](handoff/)             | Distil the session into a carry-forward note before `/clear`. |
| [panel-review](panel-review/)   | Multi-persona review of a change before PR.           |
| [plan-review](plan-review/)     | Review an implementation plan against the code before building. |
| [ticket-triage](ticket-triage/) | Gated triage of a ticket — find the problem first.    |

## Adding a skill

1. Create `skills/<name>/` with a `SKILL.md` inside.
2. Add a row to the index above.
3. The installer ([`bin/`](../bin/README.md)) picks it up automatically from the
   folder name — `bin/install.ps1 <name>` or `bin/install.sh <name>`.

> **Repo-tooling skills** — ones that only make sense inside this repo (a skill
> reviewer, linter, or scaffolder) — go in [`.claude/skills/`](../.claude/skills/)
> instead. They're project-scoped: version-controlled with the repo, loaded only
> here, and not installed globally. See that folder's README.
