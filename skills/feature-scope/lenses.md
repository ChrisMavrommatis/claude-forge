# The lenses

These are six lenses on one feature. They are the **record** — the guided walk (SKILL.md →
"The guided walk") fills them as the user settles each part. The parts are the steps you
walk; the lenses are how the scope is written down.

They all rest on **following the feature through the system** (see SKILL.md → "The main
technique"): walk where the data comes in, where it is used, what existing thing could
carry it, what would change, what breaks. A discovery pass over the code at setup (offered,
run on the user's ok) seeds this with real touch points and reuse paths, so the parts come
from the codebase and not only the request. Each thing you hit is a part to build (→ Build),
a choice (→ Build, as options + tradeoffs), or a decision (→ Unknowns, then Decided). The
parts you find are the steps the user walks.

For each lens: what to do, what not to do, and how it fills during the walk.

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
  show the error). Source the parts and choices from the discovery pass over the code where
  one ran, not only the request and memory. Tag each by what backs it: `#request`, `#code`,
  `#pattern`.
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

**The parts are the steps.** Naming the parts (and their choices) is the setup; settling them
one at a time is the walk.

**Settling a part — three ways.** For each part, show it (and its choice, if any), then ask
how the user wants to settle it:
- **Decide** — the user picks the approach, or confirms the recommended pick.
- **Tell me your approach** — the user says how they plan to build it. Before recording it,
  check the code (from the discovery pass, or a quick focused explore) for a reuse path or a
  different seam they didn't mention. If one exists, surface it as a choice against their
  approach — options, tradeoffs, a recommended pick — and let them re-decide. If nothing
  better shows up, record their stated approach.
- **Explore** — send a separate agent one focused question (for example, "does the existing
  import remove stale rows?"), it reports back, then the user decides.

**Feasibility, per part.** For each part also ask: is there anything in the code that would
block this approach — an extension point that must exist, a hook to attach to, a framework or
permission constraint? A possible-but-unconfirmed blocker is an Unknown; a confirmed hard
blocker holds the Size at Low confidence until it is resolved.

Record the result and move to the next part. Don't size until every part is settled or
explicitly left high-level.

---

## 🕳️ Unknowns

**Do:** Surface what is missing, unknown, or undecided — the questions whose answers change
the build or the size. Phrase each as a question. These are the most valuable output of the
skill: the unknowns are what someone forgets when they call it "small". Three kinds:

- **Spec unknowns** — the request doesn't say (which countries? what happens on failure?).
  Close by **asking the user**.
- **Code unknowns** — the answer is in the codebase (is there a validation hook? how many
  entry paths?). Close by **sending a separate explore agent** (the Explore option).
- **Decision unknowns** — a choice the feature forces but nobody raised (saved addresses at
  checkout — do we block invalid ones?). Found by following the feature. Close by **deciding**
  (with the user) → moves to ☑️ Decided.
- **Feasibility unknowns** — a possible blocker that isn't confirmed (does the extension point
  exist? is there a hook to attach to? does a framework or permission rule stop this?). Close
  by **sending an explore agent**. A confirmed hard blocker holds the Size at Low confidence.

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

**Depth:** name the risk when it surfaces; judge likelihood and impact when the relevant part
is settled. Confirming a risk in code is an Explore question, only when the user asks.

---

## 📏 Size

**Do:** Give the T-shirt size, the confidence, the one-line *why*, and the lever — what
would move it. Confidence is set by how the parts were settled: a part left high-level or
resting on a guess holds the size down. An unresolved hard blocker forces Low confidence no
matter how many parts are settled — the lever is "confirm the blocker." See the rubric tables
in SKILL.md.

**Don't:** ever give a bare size. Don't present a Low-confidence size as settled. Don't pad
against unknowns quietly, and don't lowball to please. If it is **L**, say it isn't small
and point to splitting or a full build-planning effort.

**When:** the size comes at the end of the walk, once the parts are settled. You can show a
running size earlier, but it is a guess until the parts are settled — say so.

---

## If the feature turns out not to be small

Scoping sometimes shows the "small feature" is a large one inside a small request. When
that happens:

- Don't keep scoping it as if it were small. Size it **L** and say so.
- Point out the natural splits — *"this is really three features: the set import, the
  validation, and an admin UI to manage the set."*
- Offer to scope one part now, or take the whole thing into a full build-planning effort.
  Let the user choose — don't restructure or escalate on your own.
