# The lenses

These are six lenses on one feature, not a fixed sequence. The first pass fills them at a
**high level**, fast. After that the user sets the depth, one lens at a time.

They all rest on **following the feature through the system** (see SKILL.md → "The main
technique"): walk where the data comes in, where it is used, what existing thing could
carry it, what would change, what breaks. Each thing you hit is a part to build (→ Build),
a choice (→ Build, as options + tradeoffs), or a decision (→ Unknowns, then Decided).

For each lens: what to do, what not to do, and how deep to go (and when to check code).

---

## 🎯 Ask

**Do:** Restate what the client wants, in one line, in plain words. Tag it `#request`. If
the request is unclear about *what* (not how), name the readings and ask which one. You
can't map what you can't pin down.

**Don't:** turn the want into a solution — that is the Build lens. Don't quietly narrow or
broaden the ask.

**Depth:** stays shallow. One line. If you can't write it with confidence, that is your
first unknown.

---

## 🧩 Build — what we'd build, and how

This is the main content: **what we'd build and the approach for each part.** "How" here is
approach-level — which mechanism, which building block, *where it connects* — never
file-by-file code.

**Do:**
- Follow the feature and name the parts of work it implies (import a set, validate on entry,
  show the error). Tag each by what backs it: `#request`, `#code`, `#pattern`.
- **At every real choice, lay out the options with their tradeoffs and a recommended pick.**
  The build-vs-reuse decision is the most useful output here. Format a choice as:
  ```
  - <the part>  ← CHOICE:
      · <option A> — <what it costs / risks / leaves unsolved>
      · <option B> — <its tradeoff>
      → pick: <which, and why, in this feature's context>  <tag>
  ```
  Example: reuse an existing import (simple, but may never remove deleted entries → stale
  set) vs. a custom importer (handles removals, more work). The consequence is part of the
  scope.
- For each part, follow **where it connects** — the touch points. "Validation runs wherever
  an address is entered" is worth more than "add validation".

**Don't:** write implementation steps, task order, or code — that is the later build plan.
Don't invent parts the request doesn't imply. Don't merge two genuinely different parts into
one to make it look smaller. **Don't quietly pick a side at a choice** — show the options,
recommend, let the user decide.

**Depth (high-level):** name the parts and the obvious choices; one line each.
**Depth (drill-in):** when asked to break a part down or weigh a choice, expand *that* one —
and this is usually where you **offer to check code**: *"to judge reuse-vs-custom I'd check
how the existing import handles deletes — want me to?"* One check, then report.

---

## 🕳️ Unknowns

**Do:** Surface what is missing, unknown, or undecided — the questions whose answers change
the build or the size. Phrase each as a question. These are the most valuable output of the
skill: the unknowns are what someone forgets when they call it "small". Three kinds:

- **Spec unknowns** — the request doesn't say (which countries? what happens on failure?).
  Close by **asking the user**.
- **Code unknowns** — the answer is in the codebase (is there a validation hook? how many
  entry paths?). Close by **offering a code check**.
- **Decision unknowns** — a choice the feature forces but nobody raised (saved addresses at
  checkout — do we block invalid ones?). Found by following the feature. Close by **deciding**
  (with the user) → moves to ☑️ Decided.

**Don't:** list generic, theoretical unknowns any senior dev could recite. An unknown earns
its place only if its answer would move the Build or the Size. Don't leave an unknown
quietly filled with an assumption — if you must assume, tag it `#assumption` and say what
rests on it.

**Depth:** unknowns are where depth *comes from*. Each closed unknown or settled choice
should move the Size confidence — say so when it does.

---

## ☑️ Decided

**Do:** Keep a short running record of the choices and decisions that are now settled — the
approach calls ("import: reuse existing") and the decisions found by following the feature
("block invalid saved addresses → yes"). Tag with the source that settled it (usually
`#user`). This stops a settled question drifting back open.

**Don't:** pad it with reasoning — the *why* lives in the prose. Keep each line to the call
itself.

**Depth:** grows as unknowns and choices close. It is the visible record of confidence
rising.

---

## ⚠️ Risks

**Do:** Flag what could go wrong — technical ("existing submit has no async hook" `#code`),
scope ("'validation' might mean format-check or real address verification — very different
sizes"), approach ("reuse-vs-custom is unresolved and drives the size"), or data ("the set
could bloat the bundle" `#assumption`). For each, note roughly how likely it is and how much
it would hurt.

**Don't:** treat every theoretical risk as a disaster. Don't bury a real risk among
boilerplate ones. A risk with no plausible trigger isn't a risk — drop it.

**Depth:** high-level names the risk; drill-in judges likelihood and impact and may check
code (offer first).

---

## 📏 Size

**Do:** Give the T-shirt size, the confidence, the one-line *why*, and the lever — what
would move it. Confidence is set by open unknowns and unsettled choices: a live
build-vs-reuse choice alone can hold a size at Low. See the rubric tables in SKILL.md.

**Don't:** ever give a bare size. Don't present a Low-confidence size as settled. Don't pad
against unknowns quietly, and don't lowball to please. If it is **L**, say it isn't small
and point to splitting or a full build-planning effort.

**Depth:** the size is always present from the first pass (even if Low confidence). It
*sharpens* as unknowns close and choices settle — it is what the whole skill moves.

---

## If the feature turns out not to be small

Scoping sometimes shows the "small feature" is a large one inside a small request. When
that happens:

- Don't keep scoping it as if it were small. Size it **L** and say so.
- Point out the natural splits — *"this is really three features: the set import, the
  validation, and an admin UI to manage the set."*
- Offer to scope one part now, or take the whole thing into a full build-planning effort.
  Let the user choose — don't restructure or escalate on your own.
