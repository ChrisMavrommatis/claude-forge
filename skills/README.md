# Skills

Claude Code slash skills. Each skill is its own folder with a `SKILL.md` and
any supporting assets (personas, templates, etc).

## Index

| Skill                         | What it does                                       |
| ----------------------------- | -------------------------------------------------- |
| [cafe](cafe/)                   | Morning brief, ordered like coffee.                   |
| [feature-scope](feature-scope/) | Map out & size a small feature before the build plan. |
| [panel-review](panel-review/)   | Multi-persona review of a change before PR.           |
| [ticket-triage](ticket-triage/) | Gated triage of a ticket — find the problem first.    |

## Adding a skill

1. Create `skills/<name>/` with a `SKILL.md` inside.
2. Add a row to the index above.
3. The installer (once built) picks it up automatically from the folder name.
