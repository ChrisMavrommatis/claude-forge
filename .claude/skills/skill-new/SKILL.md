---
name: skill-new
description: Scaffold a new skill in this repo to its conventions — collect the name, whether it's installable or project-scoped, and a one-line purpose, then create the folder in the right place with valid frontmatter and a plain-language body skeleton, add its index row, and leave it passing skill-lint and skill-review on day one. Writes files. Runs inline (not forked). Use when starting a new skill so you don't hand-build the boilerplate. Examples — `/skill-new my-tool`, `/skill-new my-tool project`.
argument-hint: [name] [installable|project]
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Bash
---

# skill-new

Scaffold a new skill in this repo, laid out to the repo's conventions. Give it a name
and whether it's installable or project-scoped, and it creates the folder with a valid
`SKILL.md`, the dev-facing files the scope needs, and an index row — a starting point
that passes `skill-lint` and `skill-review` from the first commit.

This writes files, so it only runs when you type it — it never auto-fires. It runs
inline in the current conversation; it does not fork. It creates a skeleton only; you
fill in the real body afterwards.

## Inputs

Read these from `$ARGUMENTS`. Ask for any that are missing — do not guess.

- **name** — the skill name in kebab-case (e.g. `my-tool`). Becomes the folder name and
  the frontmatter `name`.
- **scope** — `installable` or `project`:
  - **installable** — lives at `skills/<name>/`, installs globally via `bin/`. Gets
    `AGENT.md`, `README.md`, and a `.skillignore`.
  - **project** — lives at `.claude/skills/<name>/`, repo tooling only, no install step.
    Gets `SKILL.md` plus optional `AGENT.md` / `README.md`; no `.skillignore`.
- **purpose** — a one-line description of what the skill does. Seeds the frontmatter
  `description` and the body intro.

## What to do

1. Resolve `name`, `scope`, and `purpose` from `$ARGUMENTS`. Ask for whatever is missing.
2. Check the target folder does not already exist. If it does, stop and say so — do not
   overwrite.
3. Create the folder in the right place for its scope and write the files below.
4. Add the index row to the correct index — `skills/README.md` for installable,
   `.claude/skills/README.md` for project-scoped.
5. Report what you created and the next steps.

## What gets created

**Always — `SKILL.md`**

- Frontmatter with:
  - `name` equal to the folder name.
  - `description` written to the repo standard (see below), ending with an `Examples —`
    line.
  - `argument-hint` if the skill takes arguments.
  - `allowed-tools` if the skill needs tools beyond plain reasoning.
- A plain-language body skeleton with the headings the repo favours: a short intro under
  the `# <name>` title, an inputs or target section if it takes arguments, a
  `## What to do` step list, and an output or report section. Leave `TODO:` markers where
  the author fills in real content.

**Installable only** (under `skills/`)

- `AGENT.md` — a dev brief skeleton matching the repo's shape: what the skill is for, a
  mental model, a "where to look for what" table, design-history notes, and pitfalls.
- `README.md` — a dev doc with **Use it**, **File layout**, and **Install** sections.
- `.skillignore` — listing `AGENT.md` and `README.md` so they don't install into
  `~/.claude/skills/`.

**Project-scoped only** (under `.claude/skills/`)

- `SKILL.md` as above.
- `AGENT.md` and `README.md` skeletons — generate both by default, matching the sibling
  project skills; skip only if the author says so. The `README.md` carries a
  **Where it lives** section stating the skill is project-scoped, lives under
  `.claude/skills/`, is not installed, and needs no `.skillignore`.
- No `.skillignore`.

## The description standard

The frontmatter `description` is what Claude reads to decide when to load the skill, so
write it plainly and concretely:

- One or two sentences on what the skill does and when to use it.
- Plain language — no metaphor, no build-up. Cut any phrase that loses no meaning.
- State the read/write posture (read-only, or that it writes files) if it matters.
- End with an `Examples —` line showing at least one **real** invocation built from the
  skill's name (e.g. `` Examples — `/<name>` ``). Never leave a `TODO` here — the
  description is a shipped frontmatter field, so a placeholder would install as-is. Put
  `TODO:` markers only in the body, never in frontmatter.
- Keep `description` (plus `when_to_use` if present) under 1536 characters.

## Report

After scaffolding, report:

- Each file created, with its full path.
- The index row added and to which index.
- The next steps for the author: run `/skill-lint <name>` and `/skill-review <name>` on
  the result, fill in the `TODO:` markers, and — for an installable skill —
  `bin/install.ps1 <name>` when ready to install.

Create the skeleton only. Do not write the skill's real behaviour — that's the author's
job once the folder exists.
