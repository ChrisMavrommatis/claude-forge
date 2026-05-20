# Repo guide for Claude

This repo hosts Claude Code **skills** under `skills/<skill-name>/`. Each
skill is self-contained: spec files, personas, templates, and its own
working scratch space.

## Where to put draft / scratch files

When you produce **temporary or in-progress artifacts** for a skill —
design mockups, redesign drafts, exploration notes, scratch examples —
put them in that skill's local `.plans/` directory:

```
skills/<skill-name>/.plans/<filename>.md
```

Not at the repo root. Not next to the skill's shipped files. Each
skill owns its own `.plans/` so its scratch work travels with it and
doesn't pollute siblings.

`.plans/` directories at any depth are gitignored (see `.gitignore`),
so anything you save there stays local until explicitly promoted.

### What counts as a temp file

- Design drafts (e.g. `output-design.md`, `redesign-v2.md`)
- Mockups and sample outputs you want to reference during iteration
- Notes-to-self while exploring a change
- Anything you'd otherwise be tempted to put in `/tmp` or scatter at
  the repo root

### What does NOT go in `.plans/`

- The skill's actual spec files (`SKILL.md`, `details.md`, persona
  files, etc.) — those are the shipped artifact and live next to the
  skill root.
- README updates, public docs.
- Anything the skill *loads at runtime* — `.plans/` is for humans (and
  Claude during iteration), not for the skill engine.

## When promoting a draft to a real spec change

A `.plans/` doc is a discussion artifact. Once the design is agreed,
edit the relevant `SKILL.md` / `details.md` / `failure.md` / `veto.md`
directly — don't try to keep the `.plans/` doc and the spec in sync.
You can leave the `.plans/` doc behind as historical context or delete
it; either is fine.
