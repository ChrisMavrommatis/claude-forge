# skill-lint — agent brief

Read this first if you're picking up this skill cold. It orients you to what this
is, how it works, and why it is deliberately not `skill-review`.

## What this skill is for

A fast, mechanical convention check for the skills in this repo. Point it at one skill
or at `all`, and it runs a fixed set of greppable rules and returns a per-skill list of
concrete issues. It exists to catch the boring, checkable mistakes — a `name` that
doesn't match the folder, a missing index row, a dead link, a cut-phrase — without the
cost of a full review.

## Lint vs. review — the deliberate split

This repo has two skill-checkers on purpose. They are not the same tool and should not
converge.

| | `skill-lint` (this) | `skill-review` |
| --- | --- | --- |
| Speed | fast | slow, deliberate |
| Runs | inline, in the current conversation | inline, dispatches a fresh subagent — independent |
| Scope | one skill **or all** in a single pass | one skill or one plan at a time |
| Basis | mechanical rules — grep, length, file-exists, number sequence | judgment against conventions and done-criteria |
| Output | per-skill checklist of concrete issues | ranked findings + one PASS / FAIL verdict |
| Analogy | a linter (ESLint) | a code review |

The rule of thumb: if a check needs an opinion, it belongs in `skill-review`, not here.
`skill-lint` only asserts things a script could assert. Keeping that line sharp is what
makes the lint fast and the review worth dispatching a subagent for.

## Mental model

- **Prompt-based, no compiled code.** The Markdown IS the implementation. `SKILL.md`
  is the whole skill.
- **Runs inline — does not fork.** There is no `context: fork` in the frontmatter, and
  that is intentional: a mechanical check has nothing to gain from an independent cold
  read, and forking would only add latency. It also means `all` can sweep every skill
  in one pass without spawning a subagent per skill.
- **Read-only.** `allowed-tools` is limited to Read / Grep / Glob / Bash for
  inspection. It reports; it never fixes.
- **One argument.** A bare skill name lints that one; `all` (or empty) lints every
  skill under both `skills/` and `.claude/skills/`.

## Where to look for what

| I want to change                        | Edit                          |
| --------------------------------------- | ----------------------------- |
| Target resolution / argument handling   | `SKILL.md` → Target           |
| Which rules run                          | `SKILL.md` → Checks           |
| The known-valid frontmatter value set    | `SKILL.md` → Checks (Frontmatter) |
| The plain-language cut-phrase list       | `SKILL.md` → Checks (Plain language) |
| Report format / rule tags                | `SKILL.md` → Report           |
| Pre-approved tools                       | `SKILL.md` frontmatter (`allowed-tools`) |

## Design history — the big calls

- **No subagent dispatch.** `skill-review` dispatches a fresh subagent for independence;
  a linter doesn't need that and would only pay the latency. Inline also lets `all`
  cover every skill in one pass.
- **Mechanical only.** Every check is a grep, a length count, a file-exists test, or a
  number-sequence check. No rule requires judgment. If a proposed check needs an
  opinion, it is a `skill-review` check, not a lint check.
- **Reports length, doesn't just gate it.** The 1536-char description limit is reported
  as an actual count (`1204 / 1536`) so an author sees the headroom, not just a
  pass/fail.
- **No verdict.** There is no PASS / FAIL gate on the whole run — a skill either has a
  list of concrete issues or the word PASS. The gate lives in `skill-review`.

## Pitfalls / don'ts

- **Don't edit.** This is a lint. Report issues; never apply fixes.
- **Don't add judgment checks.** The moment a rule needs an opinion, it belongs in
  `skill-review`. Keep this tool strictly mechanical.
- **Don't flag a missing `.skillignore` on a project-scoped skill.** Those live under
  `.claude/skills/`, have no install step, and need no `.skillignore`.
