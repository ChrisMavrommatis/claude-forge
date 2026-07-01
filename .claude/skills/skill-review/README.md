# skill-review

An independent reviewer for the skills in this repo. Point it at a skill (or a
saved `.plans/` plan) and it re-checks the work cold — conventions, frontmatter,
plain language, coherence, and the skill's own done-criteria — then returns a
ranked findings list and a single PASS / FAIL verdict.

The review runs in a fresh subagent that the skill dispatches, so it is not coloured by
the conversation that wrote the skill. Read-only — it never edits.

## Use it

```
/skill-review <skill-name>                       # review a skill
/skill-review plan <path-to-plan.md>             # gate a completed .plans/ plan
/skill-review                                    # list skills and ask which
```

Examples:

```
/skill-review panel-review
/skill-review plan skills/cafe/.plans/improvements.md
```

Run it before installing or committing a changed skill, or to gate a plan you've
just finished executing.

## What it checks

Structure (SKILL.md / AGENT.md / README.md / .skillignore), frontmatter (name,
description length, valid fields), the repo's plain-language standard, cross-file
coherence (dangling refs, numbering, template shapes, consistent naming), behaviour
claims (read-only posture, gates, intentional voices), and the `skills/README.md`
index row. In plan mode it verifies each recommendation and done-criterion is
actually implemented.

## File layout

```text
skill-review/
├── SKILL.md        core spec — the reviewer's target resolution, checklist, report
├── AGENT.md        orientation for an agent reading this skill cold
└── README.md       you are here
```

## Where it lives

This is a **project-scoped** skill: it lives at `.claude/skills/skill-review/` inside
this repo and loads automatically whenever you work in claude-forge. It is **not**
installed into `~/.claude/skills/` and is **not** distributed by the `bin/` installer —
its checks only make sense against this repo's layout. It's version-controlled with
the repo. See [`../README.md`](../README.md) for the project-scoped skills index.
