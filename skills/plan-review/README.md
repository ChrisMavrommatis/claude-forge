# plan-review

An independent reviewer for an implementation plan, run **before any code is written**.
Point it at a `.plans/*.md` plan file and it dispatches a fresh subagent that reads the
plan and the codebase it targets, then checks the plan against the real code — every
named file exists, every "reuse X" claim is true, unknowns are surfaced, verification is
runnable, acceptance criteria are concrete, scope matches the request. It returns a
ranked findings list and a single READY / NOT-READY verdict.

The review runs in a fresh subagent that the skill dispatches, so it is not coloured by
the conversation that wrote the plan. Read-only — it never edits. This is the bookend to
planning: scope → plan → plan-review → build.

## Use it

```
/plan-review <path-to-plan.md>     # review a plan against its codebase
/plan-review                       # list .plans/*.md and ask which
```

Examples:

```
/plan-review .plans/my-feature.md
/plan-review .plans/checkout-rework.md
```

Run it after you've written a plan and before you start building from it.

## What it checks

- **Named references exist** — every file / module / API / symbol the plan names is
  confirmed in the codebase (Grep / Glob / Read). Invented references are flagged.
- **Reuse / extend claims are true** — every "we'll reuse X" / "extend Y" is verified
  against real code, and that the thing does what the plan assumes.
- **Unknowns and risks are surfaced** — not silently assumed away.
- **Verification is runnable** — there is a concrete step for how we'll know it works.
- **Acceptance criteria are testable** — concrete, not vague.
- **Scope matches the request** — no smuggled scope, no gaps.

Findings are ranked CRITICAL / MAJOR / MINOR / NIT and end in one READY / NOT-READY line.

## File layout

```text
plan-review/
├── SKILL.md        core spec — target resolution, dispatch, checklist, report
├── AGENT.md        orientation for an agent reading this skill cold
└── README.md       you are here
```

## Install

From the repo root, using the installer in [`bin/`](../../bin/README.md):

```bash
# Linux / Mac
bin/install.sh plan-review

# Windows (PowerShell)
bin\install.ps1 plan-review
```

See the parent [README](../../README.md) for repo-level context.
