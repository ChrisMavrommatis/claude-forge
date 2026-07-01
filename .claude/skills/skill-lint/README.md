# skill-lint

A fast, mechanical convention checker for the skills in this repo. Point it at one
skill or at `all`, and it runs a fixed set of greppable rules and returns a per-skill
list of concrete issues — `file:line — rule — problem`.

It's a linter, not a reviewer. It runs inline (it does **not** fork), applies only
checkable rules — no judgment, no PASS / FAIL verdict — and covers one skill or every
skill in a single pass. For a deep, independent, gate-style pass, use
[`../skill-review/`](../skill-review/) instead. Read-only — it fixes nothing.

## Use it

```
/skill-lint <skill-name>     # lint one skill
/skill-lint all              # lint every skill under skills/ and .claude/skills/
/skill-lint                  # same as `all`
```

Examples:

```
/skill-lint ticket-triage
/skill-lint all
```

Run it as a quick pre-commit sweep, or any time you just want the mechanical problems
listed without spinning up a full review.

## What it checks

- **Frontmatter** — `name` equals the folder name; `description` present and ending in
  an `Examples —` line; `description` (+ `when_to_use`) under 1536 chars (reported as an
  actual count); `allowed-tools` / `model` / `effort` / `context` / `agent` values from
  the known-valid set.
- **Structure** — `SKILL.md` present; installable skills also have `AGENT.md`,
  `README.md`, and a `.skillignore` that lists both; project-scoped skills need no
  `.skillignore`.
- **Index** — a row in the correct index (`skills/README.md` or
  `.claude/skills/README.md`).
- **Plain language** — the repo's cut-phrase list, reported with `file:line`.
- **Coherence** — dead relative markdown links; duplicate or skipped numbers in
  numbered lists.

## lint vs. review

| | skill-lint | skill-review |
| --- | --- | --- |
| Speed / run | fast, inline | slow; dispatches a subagent |
| Scope | one skill **or all** | one skill or plan |
| Basis | mechanical rules | judgment |
| Output | per-skill issue list | ranked findings + PASS / FAIL |

If a check needs an opinion, it lives in `skill-review`. skill-lint only asserts what a
script could assert.

## File layout

```text
skill-lint/
├── SKILL.md        core spec — target resolution, checks, report format
├── AGENT.md        orientation for an agent reading this skill cold
└── README.md       you are here
```

## Where it lives

This is a **project-scoped** skill: it lives at `.claude/skills/skill-lint/` inside this
repo and loads automatically whenever you work in claude-forge. It is **not** installed
into `~/.claude/skills/` and is **not** distributed by the `bin/` installer — its checks
only make sense against this repo's layout. It's version-controlled with the repo, and
therefore needs no `.skillignore`. See [`../README.md`](../README.md) for the
project-scoped skills index.
