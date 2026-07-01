---
name: skill-lint
description: Fast, mechanical convention check for the skills in this repo — lint one skill or all of them in a single inline pass and get a per-skill checklist of concrete issues (frontmatter, structure, index row, plain-language cut-phrases, dead links, list numbering). No deep judgment, no verdict — just checkable rules, like a linter. Read-only, fixes nothing. Runs inline (not forked). Use for a quick pre-commit sweep, or when you just want the mechanical problems listed. Examples — `/skill-lint`, `/skill-lint ticket-triage`, `/skill-lint all`.
argument-hint: [skill-name | all]
allowed-tools: Read, Grep, Glob, Bash
---

# skill-lint

A fast, mechanical convention checker for the skills in this repo. Point it at one
skill or at `all`, and it runs a fixed set of greppable checks and reports concrete
issues as `file:line — rule — problem`.

This is a linter, not a reviewer. It runs inline in the current conversation — it does
**not** fork. It applies only rules that can be checked mechanically: no judgment about
whether a skill is well-designed, and no PASS / FAIL verdict. For that, use
`skill-review`. Read-only — it fixes nothing.

## Target

`$ARGUMENTS` names what to lint:

- `<skill-name>` — the skill at `skills/<skill-name>/`, or the project-scoped tool at
  `.claude/skills/<skill-name>/` (e.g. `ticket-triage`, or `skill-lint` itself).
- `all` — every skill under both `skills/` and `.claude/skills/`.
- empty — default to `all`.

## What to do

1. Resolve the target list from `$ARGUMENTS`.
2. For each skill, work out where it lives:
   - **installable** — under `skills/`.
   - **project-scoped** — under `.claude/skills/`.
3. Run the checks below against that skill's shipped files. Cite `file:line` for every
   issue.
4. Report in the format at the end.

## Checks

All checks are mechanical — a grep, a length count, a file-exists test, or a number
sequence. Do not exercise judgment. If a rule can't be checked by one of those, it's
not a skill-lint check.

**Frontmatter** (`SKILL.md` YAML)
- `name` is present and equals the folder name.
- `description` is present.
- `description` + `when_to_use` (if `when_to_use` is present) combined is under 1536
  characters. Always **report the actual length**, e.g. `1204 / 1536`.
- `description` ends with an `Examples —` line.
- Any `allowed-tools`, `model`, `effort`, `context`, `agent`, or
  `disable-model-invocation` value is from the known set below. Flag anything outside it.
  Other keys (`name`, `description`, `argument-hint`, `when_to_use`) aren't value-checked.

Known-valid values:
- `context`: `fork`
- `agent`: `general-purpose`
- `allowed-tools`: any comma-separated list of `Read`, `Grep`, `Glob`, `Bash`, `Edit`,
  `Write`
- `model`: `haiku`, `sonnet`, `opus`, `fable`
- `effort`: `low`, `medium`, `high`
- `disable-model-invocation`: `true` or `false`

**Structure**
- `SKILL.md` is present.
- **installable skills** (under `skills/`): `AGENT.md`, `README.md`, and `.skillignore`
  all exist, and both `AGENT.md` and `README.md` are listed in `.skillignore`.
- **project-scoped skills** (under `.claude/skills/`): no `.skillignore` is expected —
  do not flag its absence.

**Index**
- The skill has a row in the correct index: `skills/README.md` for an installable skill,
  `.claude/skills/README.md` for a project-scoped one. Flag a missing row.

**Plain language**
- Grep the skill's shipped files for these cut-phrases and report every hit with
  `file:line`: `heart of`, `the engine`, `the spine`, `load-bearing`, `marquee`,
  `the crux`, `the ballgame`, `sails through`, `bite us`, `burned by`,
  `wearing a small request`.
- Skip false positives: a match that IS the ban-list itself — these phrases quoted as a
  list, e.g. inside `skill-review`'s or `skill-lint`'s own checks — is not prose. Only
  flag a cut-phrase actually used in the skill's own writing.

**Coherence** (mechanical only)
- Markdown links (`[text](path)`) pointing to a relative file that does not exist. Flag
  the dead link with its `file:line`. Skip external `http(s)://` links and pure
  `#anchor` links.
- Numbered lists (guardrails, steps) with a duplicate or skipped number. Flag the break
  with its `file:line`.

## Report

**One skill** — a compact block:

```
skill-lint · ticket-triage (installable)

PASS
```

or, if there are issues:

```
skill-lint · ticket-triage (installable)

3 issues
- SKILL.md:3 — frontmatter/description-length — 1602 / 1536, over limit
- SKILL.md:44 — coherence/dead-link — links steps.md, file not found
- steps.md:12 — plain-language — "load-bearing"
```

**All skills** — a one-line-per-skill summary table first, then the detail blocks for
every skill that has issues:

```
Skill               Scope          Result
ticket-triage       installable    3 issues
cafe                installable    PASS
skill-review        project        PASS
skill-lint          project        1 issue
```

Then, below the table, one detail block (as above) per skill with issues. Skills that
PASS need no detail block.

Each issue line is `file:line — rule — problem`. Use these rule tags: `frontmatter/*`
(`name-mismatch`, `description-missing`, `description-length`, `examples-line`,
`invalid-value`), `structure/*` (`missing-file`, `skillignore-missing`,
`skillignore-entry`), `index/missing-row`, `plain-language`, `coherence/dead-link`,
`coherence/list-numbering`.

Do not edit any files. This is a lint. Report only.
