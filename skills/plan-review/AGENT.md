# plan-review — agent brief

Read this first if you're picking up this skill cold. It orients you to what this is,
how it works, and the calls behind it.

## What this skill is for

Independent review of an implementation plan (a `.plans/*.md` file) **before any code is
written**. It produces a ranked findings list and a single READY / NOT-READY verdict. It
exists to catch the failures that make a plan expensive to build from — files the plan
names that don't exist, "we'll reuse X" claims that aren't true, unknowns assumed away,
no runnable verification, vague acceptance criteria, smuggled scope — while they are
still cheap to fix. It is the bookend to planning: scope → plan → plan-review → build.

## Mental model

- **Prompt-based, no compiled code.** The Markdown IS the implementation. `SKILL.md`
  is the whole skill; there are no supporting runtime files.
- **Runs inline, dispatches a subagent.** The skill resolves the target inline (so it
  receives `$ARGUMENTS`), then dispatches a fresh general-purpose subagent to do the
  review. Independence comes from that subagent's clean context — not from a forked
  skill invocation, which would **not** receive the target argument in this harness.
- **Read-only.** `allowed-tools` is the read tools (Read / Grep / Glob / Bash) plus the
  Agent dispatch; the review itself edits nothing. Findings are reported, not applied.
- **The review checks the plan against real code.** The value is in not taking the
  plan's word for anything checkable — every named reference and reuse claim is verified
  with Grep / Glob / Read against the codebase the plan targets.
- **General-purpose, not repo-specific.** It reviews any repo's plan file. Its own home
  is claude-forge, but its logic assumes nothing about this repo's layout.

## Where to look for what

| I want to change                        | Edit                          |
| --------------------------------------- | ----------------------------- |
| Target resolution / argument handling   | `SKILL.md` → Target           |
| What gets checked                       | `SKILL.md` → Checklist        |
| Report format / severity scale          | `SKILL.md` → Report           |
| How the review is dispatched            | `SKILL.md` → How it runs      |
| Pre-approved tools                      | `SKILL.md` frontmatter (`allowed-tools`) |

## Design history — the big calls

- **Independent via a dispatched subagent.** The review must not see the conversation
  that wrote the plan, or it inherits its blind spots. This is built inline (to read the
  arg) + dispatch a fresh subagent (for the cold read) from the start — deliberately
  **not** `context: fork`, because a forked skill doesn't receive its target argument in
  this harness (this was found the hard way on `skill-review` and is why that one was
  redesigned the same way). Same independence, one level down.
- **READY / NOT-READY, not PASS / FAIL.** The output gates a concrete action — start
  building or don't. A plan isn't "passing"; it's ready-to-build-or-not. Same shape as
  `skill-review`'s report, different verdict words to fit what's being judged.
- **Checklist verifies against code, not just reads the plan.** The failures worth
  catching (invented files, false reuse claims, hand-waved unknowns) are only visible by
  checking the plan against the real codebase — so the checklist tells the subagent to
  confirm every checkable claim with Grep / Glob / Read and cite `file:line`.
- **General-purpose.** It assumes nothing about the claude-forge layout so it works on
  any repo's plan file.

## Pitfalls / don'ts

- **Don't edit.** This is a review. Report findings; never apply them.
- **Don't run the review inline.** Dispatch the subagent — running it in this
  conversation would inherit the authoring context and defeat the independence.
- **Don't take the plan's word for it.** A named file or a "reuse X" claim is a finding
  until you've confirmed it in the code. Cite `file:line`.
- **Don't dispatch without a target.** No argument → list the `.plans/*.md` files and
  ask which; never default to a random plan.
- **Don't return READY without a reason.** READY means the checklist was actually run
  against the code and nothing failed — not that the plan read plausibly.
