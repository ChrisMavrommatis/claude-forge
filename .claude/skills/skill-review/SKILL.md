---
name: skill-review
description: Independently review one skill in this repo — or a saved `.plans/` plan — against the repo conventions, frontmatter rules, the plain-language standard, and the skill's own done-criteria, then return a ranked findings list and a single PASS / FAIL verdict. Runs as a fresh subagent so the review is independent of the conversation that wrote the skill. Read-only. Use before installing or committing a changed skill, or to gate a completed plan. Examples — `/skill-review panel-review`, `/skill-review plan skills/cafe/.plans/improvements.md`.
argument-hint: [skill-name | plan <path>]
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# skill-review

Review one skill in this repo — or a saved `.plans/` plan — against the repo's
conventions and the skill's own done-criteria, and return a ranked findings list
with one PASS / FAIL verdict.

The review runs in a **fresh subagent that this skill dispatches**, so it does not see
the conversation that wrote the skill. That independence is the point: a cold read
re-checks the work with skeptical eyes. Read-only — nothing is edited.

## Target

The review target comes from the invocation argument (`$ARGUMENTS`). Resolve it first,
before reading anything. **Never assume the target is the skill you are running from** —
if the argument names a skill, review *that* skill, not `skill-review`.

- `<skill-name>` — the skill at `skills/<skill-name>/`, or the project-scoped tool at
  `.claude/skills/<skill-name>/` (e.g. `panel-review`).
- `plan <path>` — a plan file (e.g. `plan skills/cafe/.plans/improvements.md`):
  confirm every recommendation and done-criterion in the plan is implemented in the
  matching skill.
- **no target given** — do NOT default to reviewing `skill-review` or any one skill.
  List the folders under `skills/` and `.claude/skills/`, ask which one to review, and
  stop.

## How it runs

This skill runs **inline** — it is not a forked skill, because a forked skill would not
receive the target argument. It does three things:

1. **Resolve the target** from `$ARGUMENTS` (see above). If there is no target, list the
   skills and stop — do not dispatch.
2. **Dispatch one fresh general-purpose subagent** (read-only) to do the review. Give it
   the resolved target and the checklist + report format below. The subagent starts with
   a clean context — that is what makes the review independent of this conversation. Tell
   it to read every file in the skill (or the plan plus the skill it targets) —
   `SKILL.md`, any supporting `.md`, `templates/`, `AGENT.md`, `README.md`, `.skillignore`
   — not skim, and to cite `file:line` for every finding.
3. **Relay** the subagent's ranked findings and its single verdict back to the user.

Do not run the review in this inline context yourself — dispatch it, so the read stays
independent.

## Checklist — for the dispatched subagent

**Structure**
- `SKILL.md` present, with YAML frontmatter.
- An installable skill under `skills/`: `AGENT.md` and `README.md` present, both
  listed in `.skillignore`, and `.skillignore` present (those two are dev-facing and
  must not install into `~/.claude/skills/`).
- A project-scoped tool under `.claude/skills/`: no `.skillignore` needed (no install
  step); `AGENT.md` / `README.md` are optional dev docs.

**Frontmatter**
- `name` matches the folder name.
- `description` is present and ends with an `Examples —` line.
- `description` + `when_to_use` combined is under 1536 characters (the auto-invocation
  truncation limit). Flag if over.
- Any `allowed-tools`, `model`, `effort`, `context`, or `agent` field is a valid value.

**Plain language** (repo standard — no embellishment)
- Grep the spec files and templates for these and flag any hit: `heart of`,
  `the engine`, `the spine`, `load-bearing`, `marquee`, `the crux`, `the ballgame`,
  `sails through`, `bite us`, `burned by`, `wearing a small request`.
- Prose reads in short, literal sentences. No metaphor or rhetorical build-up.
- Icons, tags, headings, tables, and technical terms are left intact — plainness is
  about prose, not stripping content.

**Coherence**
- No dangling cross-reference (a linked file or named section that doesn't exist).
- Numbered lists (guardrails, steps) are sequential — no duplicate or skipped number.
- Templates match the shapes `SKILL.md` describes.
- Names (lenses, steps, source tags, personas, catalog IDs) are consistent across
  every file — nothing renamed in one file but not another.

**Behavior**
- The read-only / write-scope claims in the spec match what the steps actually do.
- Gates and stop conditions stated in one file aren't contradicted in another.
- Any voice or naming the skill declares as intentional (e.g. a persona's voice) is
  intact, not flattened.

**Index**
- The relevant index has a row for this skill: `skills/README.md` for an installable
  skill, or `.claude/skills/README.md` for a project-scoped tool.

**Plan mode only** (`plan <path>`)
- For each recommendation (R1, R2, …) and each done-criterion in the plan, find where
  it is implemented in the target skill and cite it. Flag any that are missing,
  partial, or contradicted.

## Report

- A ranked list of problems, most severe first, one per line:
  `file:line — SEVERITY — what's wrong`. Severity is CRITICAL / MAJOR / MINOR / NIT.
- Then one explicit final line: **PASS** (conventions met, safe to install or commit)
  or **FAIL** (list what must be fixed first).
- If nothing is wrong, say so and return **PASS**.

Do not edit any files. This is a review.
