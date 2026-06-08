# feature-scope

Someone asks for "a small feature" — add zipcode validation, export to CSV, whatever.
Before you quote it or plan the build, this skill **maps it out**: what we'd build, *how*
we'd approach each part, where it touches the system, what decisions it forces, what could
go wrong, and a **defensible size**.

It is the thinking you do *before* the detailed build plan:

```
feature-scope          →   build plan        →   build
WHAT · HOW · HOW BIG        the exact steps        do it
```

This works out *what* the feature really takes, *how* you'd approach it, and *how big* it
is. The build plan works out the exact steps. Don't reach for the plan until the scope is
solid.

## What makes it useful

The high-value part is **"what we'd build *and how*"** — and "how" at the level that changes
the size:

- **Choices with tradeoffs.** Reuse an existing import, or build a custom one? They differ —
  e.g. the existing one may never remove entries deleted upstream (stale set), a custom one
  can (more work). The skill lays out the options, the tradeoff, and a recommended pick —
  then *you* call it. It never picks on its own.
- **Following the feature through the system.** It walks the feature end-to-end to find the
  touch points and the decisions nobody asked — "checkout has saved addresses → do we block
  invalid ones?" That walk is the main technique.
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

- **Guided, one part at a time.** It lists the parts of the feature, then walks them with you
  one by one. For each part you decide the approach, tell it your plan, or ask it to explore —
  then move to the next.
- **Honest sizing.** Never a bare size. Confidence is set by how the parts were settled — a
  part left high-level or resting on a guess holds the size down. Settling a part moves it.
- **Known vs. assumed, kept apart.** Every detail that drives the approach or the size
  carries a source tag (`#code`, `#pattern`, `#user`, `#request`, `#assumption`). A size
  resting on assumptions is flagged as such.
- **Explores through a separate agent, only when asked.** When you pick Explore on a part, it
  sends a separate agent to investigate one focused question and report back; you decide.
  Read-only throughout; it never edits.

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

## Not this skill

- Bugs and vague complaints → `/ticket-triage`.
- Working out the exact build (task order, file-by-file changes) → a later build plan.
- Large multi-team epics → too big; an **L** result is a signal to split or escalate.
