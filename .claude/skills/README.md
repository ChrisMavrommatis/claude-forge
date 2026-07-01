# Project-scoped skills

Repo-tooling skills that only make sense inside claude-forge — things that maintain
this repo's own skills (review, lint, scaffold), not general-purpose capabilities.

Unlike the skills in [`../../skills/`](../../skills/) — which install into
`~/.claude/skills/` via [`bin/`](../../bin/README.md) and run in any project — these
live here, are version-controlled with the repo, and load automatically **only** when
you're working in claude-forge. There is no install step.

## Index

| Skill | What it does |
| ----- | ------------ |
| [skill-review](skill-review/) | Independent PASS / FAIL review of a skill (or a `.plans/` plan) against the repo's conventions. Runs inline, dispatches a fresh subagent, read-only. |
| [skill-lint](skill-lint/) | Fast, mechanical convention check for one skill or all of them — frontmatter, structure, index row, plain-language cut-phrases, dead links, list numbering. Runs inline, read-only. |
| [skill-new](skill-new/) | Scaffold a new skill to the repo's conventions — collect name, scope, and purpose, create the folder with valid frontmatter and a body skeleton, and add its index row. Writes files; runs inline. |

## Adding one

1. Create `.claude/skills/<name>/SKILL.md`. It auto-loads in this repo — no install.
2. Add a row to the index above.

Use this home for tools that maintain the repo's own skills. Use
[`../../skills/`](../../skills/) for general-purpose skills meant to install globally.
