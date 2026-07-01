# skill-new

Scaffolds a new skill in this repo to its conventions. Give it a name, a scope
(installable or project-scoped), and a one-line purpose, and it creates the folder in the
right place with a valid `SKILL.md`, the dev-facing files the scope needs, and an index
row — a starting shell that passes `skill-lint` and `skill-review` on day one.

It writes files, so it only runs when you type it (`disable-model-invocation: true`) —
it never auto-fires. It runs inline (it does **not** fork) and produces a skeleton only;
you fill in the real body afterwards.

## Use it

```
/skill-new <name>                 # asks for scope and purpose
/skill-new <name> installable     # installable skill under skills/
/skill-new <name> project         # project-scoped skill under .claude/skills/
```

Examples:

```
/skill-new my-tool
/skill-new my-tool project
```

After it runs, fill in the `TODO:` markers, then run `/skill-lint <name>` and
`/skill-review <name>` on the result. For an installable skill, install it with
`bin/install.ps1 <name>` when it's ready.

## What it creates

- **Always** — `SKILL.md` with valid frontmatter (`name` matching the folder, a
  repo-standard `description` ending in an `Examples —` line, an `argument-hint` if it
  takes args) and a plain-language body skeleton.
- **Installable** (under `skills/`) — also `AGENT.md`, `README.md`, and a `.skillignore`
  listing both.
- **Project-scoped** (under `.claude/skills/`) — optional `AGENT.md` / `README.md`
  skeletons, no `.skillignore`.
- An index row in the correct index (`skills/README.md` or `.claude/skills/README.md`).

## File layout

```text
skill-new/
├── SKILL.md        core spec — inputs, scaffolding steps, description standard, report
├── AGENT.md        orientation for an agent reading this skill cold
└── README.md       you are here
```

## Where it lives

This is a **project-scoped** skill: it lives at `.claude/skills/skill-new/` inside this
repo and loads automatically whenever you work in claude-forge. It is **not** installed
into `~/.claude/skills/` and is **not** distributed by the `bin/` installer — it only
makes sense against this repo's layout. It's version-controlled with the repo, and
therefore needs no `.skillignore`. See [`../README.md`](../README.md) for the
project-scoped skills index.
