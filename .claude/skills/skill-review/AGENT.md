# skill-review — agent brief

Read this first if you're picking up this skill cold. It orients you to what this
is, how it works, and the calls behind it.

## What this skill is for

Independent review of one skill in this repo (or a saved `.plans/` plan) against the
repo's conventions and the skill's own done-criteria. It produces a ranked findings
list and a single PASS / FAIL verdict. It exists to make "is this skill done and
correct?" a one-keystroke check instead of a manual pass.

## Mental model

- **Prompt-based, no compiled code.** The Markdown IS the implementation. `SKILL.md`
  is the whole skill; there are no supporting runtime files.
- **Runs inline, dispatches a subagent.** The skill resolves the target inline (so it
  receives `$ARGUMENTS`), then dispatches a fresh general-purpose subagent to do the
  review. Independence comes from that subagent's clean context — not from a forked
  skill invocation, which would not receive the target argument.
- **Read-only.** `allowed-tools` is the read tools (Read / Grep / Glob / Bash) plus the
  Agent dispatch; the review itself edits nothing. Findings are reported, not applied.
- **Two modes, chosen by the argument.** A bare skill name reviews that skill; a
  `plan <path>` argument reviews a plan against the skill it targets (did every
  recommendation land?).

## Where to look for what

| I want to change                        | Edit                          |
| --------------------------------------- | ----------------------------- |
| Target resolution / argument handling   | `SKILL.md` → Target           |
| What gets checked                       | `SKILL.md` → Checklist        |
| The plain-language cut-phrase list      | `SKILL.md` → Checklist (Plain language) |
| Report format / severity scale          | `SKILL.md` → Report           |
| How the review is dispatched            | `SKILL.md` → How it runs      |
| Pre-approved tools                      | `SKILL.md` frontmatter (`allowed-tools`) |

## Design history — the big calls

- **Independent via a dispatched subagent.** The review must not see the authoring
  conversation, or it inherits its blind spots. This first used `context: fork`, but a
  forked skill doesn't receive its target argument in this harness — so the skill runs
  inline (to read the arg) and dispatches a fresh subagent (for the cold read). Same
  independence, one level down. Mirrors the manual pattern the repo already used —
  spawning a fresh reviewer agent per skill.
- **PASS / FAIL, not a score.** The output gates a concrete action (install, commit,
  delete a completed plan), so it ends with one unambiguous verdict.
- **Checklist encodes the repo's conventions.** Structure, `.skillignore` rules,
  frontmatter limits, and the plain-language cut-phrase list are the same standards
  applied by hand elsewhere — codified so they run the same way every time.
- **Plan mode.** A completed `.plans/` plan is gated by verifying each recommendation
  and done-criterion is implemented, so a plan is only deleted once its work is real.

## Pitfalls / don'ts

- **Don't edit.** This is a review. Report findings; never apply them.
- **Don't skim.** Read every file in the skill, not just `SKILL.md` — most coherence
  bugs live in the gaps between files.
- **Don't pass without a reason.** A PASS means the checklist was actually run and
  nothing failed — not that the skill looked fine at a glance.
