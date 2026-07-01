# feature-scope

Someone asks for "a small feature" — add zipcode validation, export to CSV, whatever.
Before you quote it or plan the build, this skill works it out against the actual code: how
you'd build each part, whether it's feasible here, where it touches the system, what the
paths and tradeoffs are, what could go wrong, and a **defensible size**.

It is the thinking you do *before* the detailed build plan:

```
feature-scope          →   build plan        →   build
WHAT · HOW · HOW BIG        the exact steps        do it
```

This works out *what* the feature really takes, *how* you'd approach it, and *how big* it
is. The build plan works out the exact steps. Don't reach for the plan until the scope is
solid.

## What makes it useful

The high-value part is **"how you'd build it, and whether it's feasible here"** — worked out
against the code, at the level that changes the size:

- **Discovery first.** At setup it offers a read-only pass over the codebase — where this
  would connect, what it could reuse, what would block the obvious approach — so the parts and
  the choices come from real code, not just the request and memory. Offered and run on your
  ok, never fired automatically.
- **Choices with tradeoffs.** Reuse an existing import, or build a custom one? They differ —
  e.g. the existing one may never remove entries deleted upstream (stale set), a custom one
  can (more work). The skill lays out the options, the tradeoff, and a recommended pick —
  then *you* call it. It never picks on its own. Even when you state your own approach, it
  checks the code for a reuse path or a different seam first and surfaces it as a choice.
- **Feasibility per part.** For each part it asks whether anything in the code would block the
  approach. An unresolved hard blocker holds the size at Low confidence until confirmed.
- **Following the feature through the system.** It walks the feature end-to-end — against a
  repeatable checklist (entry points, data model, permissions, async work, public contract,
  tests, config, i18n) — to find the touch points and the decisions nobody asked, like
  "checkout has saved addresses → do we block invalid ones?" That walk is the main technique.
- **"How" stays approach-level.** Which mechanism, which building block, where it connects —
  not file-by-file code. That is the later build plan's job.

## The lenses

- 🎯 **Ask** — what the client wants, in one line.
- 🧩 **Build** — what we'd build and *how*; choices shown as options + tradeoffs + a pick.
- 🕳️ **Unknowns** — what's missing / unknown / undecided. *The most valuable output.*
- ☑️ **Decided** — the choices and decisions you've settled.
- ⚠️ **Risks** — what could go wrong, technically or in scope.
- 📏 **Size** — a T-shirt size (XS/S/M/L) + confidence (Low/Med/High), with the *why* and
  what would sharpen it.

## How it behaves

- **Discovery, then a guided walk one part at a time.** It offers a read-only code pass at
  setup, then lists the parts of the feature and walks them with you one by one. For each part
  you decide the approach, tell it your plan, or ask it to explore — then move to the next.
- **Honest sizing.** Never a bare size. Confidence is set by how the parts were settled — a
  part left high-level or resting on a guess holds the size down; an unresolved hard blocker
  holds it at Low. Settling a part moves it.
- **Known vs. assumed, kept apart.** Every detail that drives the approach or the size
  carries a source tag (`#code`, `#pattern`, `#user`, `#request`, `#assumption`). A size
  resting on assumptions is flagged as such.
- **Reads the code through a separate agent, offered before it runs.** A broad discovery pass
  at setup, then focused per-part explores — both offered and run on your ok. It sends a
  separate agent to investigate the question and report back; you decide. Read-only
  throughout; it never edits.

## Use it

```
/feature-scope            # paste the request → start a new scope
/feature-scope <name>     # resume an existing scope from .plans/
```

It also tends to start when you say "the client wants…" / "we need to add…". The slash
command is the reliable trigger.

## The record

A scope is one flat, descriptively-named file in `.plans/` (e.g.
`.plans/zipcode-validation.md`) — a status block for the at-a-glance view plus the fuller
record below it. When the scope is solid, the skill offers to hand the file off to a
build-planning step as its starting brief. The handoff is always your call.

## File layout

```text
feature-scope/
├── SKILL.md            core spec — the part-by-part scoping flow
├── lenses.md           the six lenses (Ask, Build, Unknowns, Decided, Risks, Size)
├── templates/
│   ├── README.md       templates overview
│   └── scope.md        the flat scope record written to .plans/
├── AGENT.md            orientation for an agent reading this skill cold
└── README.md           you are here
```

## Install

From the repo root, using the installer in [`bin/`](../../bin/README.md):

```bash
# Linux / Mac
bin/install.sh feature-scope

# Windows (PowerShell)
bin\install.ps1 feature-scope
```

See the parent [README](../../README.md) for repo-level context.

## Not this skill

- Bugs and vague complaints → `/ticket-triage`.
- Working out the exact build (task order, file-by-file changes) → a later build plan.
- Large multi-team epics → too big; an **L** result is a signal to split or escalate.
