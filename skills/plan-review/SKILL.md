---
name: plan-review
description: Independently review an implementation plan BEFORE any code is written — a fresh subagent reads the plan and the codebase it targets, and checks that every file / API / symbol the plan names actually exists, that each "reuse X" / "extend Y" claim is verified against real code, that unknowns and risks are surfaced, that there is a runnable verification step, and that acceptance criteria are concrete and the scope matches the request. Returns a ranked findings list and one READY / NOT-READY verdict. Read-only. Use before you start building from a saved `.plans/*.md` plan. Examples — `/plan-review .plans/my-feature.md`, `/plan-review .plans/checkout-rework.md`.
argument-hint: <path-to-plan.md>
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# plan-review

Review an implementation plan **before any code is written**, and return a ranked
findings list with one READY / NOT-READY verdict. READY means the plan is safe to start
building from; NOT-READY means fix these things first.

The review runs in a **fresh subagent that this skill dispatches**, so it does not see
the conversation that wrote the plan. That independence is the point: a cold read
checks the plan against the actual codebase with skeptical eyes, catching invented files,
unverified "we'll reuse X" claims, and hand-waved unknowns before they cost build time.
Read-only — nothing is edited.

This is the bookend to planning: scope → plan → **plan-review** → build.

## Target

The review target comes from the invocation argument (`$ARGUMENTS`) — the path to the
plan file, e.g. `.plans/my-feature.md`. Resolve it first, before reading anything.

- `<path-to-plan.md>` — review the plan at that path against the codebase it targets.
- **no target given** — do NOT default to a random plan. List the `.plans/*.md` files
  you can find (search the repo), ask which one to review, and stop. Do not dispatch
  without a target.

## How it runs

This skill runs **inline** — it is not a forked skill, because a forked skill would not
receive the target argument in this harness. It does three things:

1. **Resolve the target** from `$ARGUMENTS` (see above). If there is no target, list the
   `.plans/*.md` files and stop — do not dispatch.
2. **Dispatch one fresh general-purpose subagent** (read-only) to do the review. Give it
   the resolved plan path and the checklist + report format below. The subagent starts
   with a clean context — that is what makes the review independent of this conversation.
   Tell it to read the whole plan, then confirm the plan's claims against the real
   codebase with Grep / Glob / Read, and to cite `file:line` for every finding (both in
   the plan and in the code it checked).
3. **Relay** the subagent's ranked findings and its single verdict back to the user.

Do not run the review in this inline context yourself — dispatch it, so the read stays
independent and doesn't inherit this conversation's assumptions.

## Checklist — for the dispatched subagent

Read the whole plan first. Then verify each claim against the codebase — do not take the
plan's word for anything checkable.

**Named references exist**
- Every file, module, class, function, API, endpoint, config key, or symbol the plan
  NAMES actually exists. Grep / Glob / Read to confirm. Flag any reference you cannot
  find in the codebase as invented (CRITICAL if the plan builds on it).

**Reuse / extend claims are true**
- Every "we'll reuse X", "extend Y", "call into Z", "this already does W" claim is
  verified against real code. Confirm the thing exists AND does what the plan assumes it
  does. Flag assumptions stated as facts — a claim about existing behaviour that isn't
  backed by the code you read.

**Unknowns and risks are surfaced**
- Real unknowns are listed as unknowns, not silently assumed away. Flag anywhere the plan
  glides past a dependency, a migration, an integration point, or an edge case as if it
  were settled when the code shows it isn't.

**Verification is concrete and runnable**
- There is a concrete, RUNNABLE step for how we'll know it works — a test to run, a
  command, an observable behaviour. Flag "we'll test it" with no specifics.

**Acceptance criteria are testable**
- Acceptance criteria are concrete and testable, not vague. "Works correctly" is not a
  criterion; "endpoint returns 400 on empty body" is. Flag vague criteria.

**Scope matches the request**
- The plan's scope matches what was asked for. Flag smuggled scope — work the plan adds
  that the request did not call for — and flag gaps where the request is not covered.

## Report

- A ranked list of problems, most severe first, one per line:
  `location — SEVERITY — what's wrong`, where `location` is `plan:line` or the
  `file:line` in the codebase the finding is about. Severity is
  CRITICAL / MAJOR / MINOR / NIT.
- Then one explicit final line: **READY** (the plan is safe to start building from) or
  **NOT-READY** (list what must be fixed first).
- If nothing is wrong, say so and return **READY**.

Do not edit any files. This is a review.
