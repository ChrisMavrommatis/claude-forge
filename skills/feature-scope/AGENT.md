# feature-scope — agent brief

Read this first if you're picking up this skill cold. It tells you what this is, how it
works, and the decisions behind it.

## What this skill is for

Mapping and sizing a *small new feature* before any commitment to build it. The default
Claude behaviour — hear "add zipcode validation", agree it's small, start coding — is what
this prevents. The skill makes you work out **what we'd build and *how*** (approach-level,
with build-vs-reuse choices written out as options + tradeoffs), **follow it through the
system** to find touch points and decisions, surface the unknowns and risks, and put a
defensible T-shirt size on it. It is the thinking *before* the detailed build plan:
**feature-scope = what, how, how big; the build plan = the exact steps.**

## Mental model

- **The skill is prompt-based.** No compiled code. The Markdown is the implementation.
  `SKILL.md` is the always-loaded core; `lenses.md` is read on start; `templates/` is read
  only when creating the scope file.
- **Six lenses are the record, not the steps.** 🎯 Ask · 🧩 Build · 🕳️ Unknowns · ☑️ Decided ·
  ⚠️ Risks · 📏 Size. The guided walk fills them as the user settles each part. The parts are
  the steps; the lenses are how the scope is written down.
- **It is a guided walk, one part at a time.** Setup pins the ask and lists the parts; then
  the user settles each part in turn — by deciding, stating an approach, or asking to
  explore. Don't jump ahead; size only when every part is settled.
- **The main technique is following the feature through the system.** Walk where data comes
  in, where it is used, what existing thing could carry it, what breaks. Each thing hit is a
  part to build, a choice, or a decision. The parts it finds become the steps the user walks.
- **"How" is approach-level, on purpose.** Which mechanism (reuse vs. custom), which building
  block, *where it connects* — never file-by-file code or task order. The detailed plan is a
  later step. If you catch yourself writing steps, stop.
- **Choices are first-class.** Build-vs-reuse and which-mechanism are real decisions with
  consequences (e.g. reuse may never delete stale entries; custom can). Always lay out
  options + tradeoffs + a recommended pick, and let the user choose. Never pick on your own.
- **Known vs. assumption matters.** A known is source-tagged (`#code #pattern #user
  #request`); an assumption (`#assumption`) is a labelled guess. The skill exists to stop an
  approach or size built on guesses from looking grounded. `#request` is the weakest real tag
  — a want, not a spec.
- **Unknowns (and unsettled choices) drive confidence.** Size confidence (Low/Med/High)
  depends on how many unknowns and choices are still open. Closing one should visibly move
  the size — say so.
- **Read-only.** Reads code/patterns to back up the map; writes only `.plans`. Never edits,
  never builds.

## Where to look for what

| I want to change                          | Edit                                       |
| ----------------------------------------- | ------------------------------------------ |
| Invocation / triggers / resume             | `SKILL.md` → How to invoke                 |
| The guardrails                              | `SKILL.md` → Guardrails                    |
| The follow-the-feature technique            | `SKILL.md` → The main technique            |
| The "how = approach, not code" boundary    | `SKILL.md` → What "how" means here         |
| Source-tag list                             | `SKILL.md` → Knowns and guesses            |
| The guided walk + per-part settling         | `SKILL.md` → The guided walk               |
| The T-shirt + confidence rubric             | `SKILL.md` → The size                      |
| The status-block shape / icons              | `SKILL.md` → The status block              |
| Handoff to a build-planning step            | `SKILL.md` → Handoff                       |
| Per-lens behaviour, do/don't, how deep      | `lenses.md`                                |
| The scope-file shape                        | `templates/scope.md`                       |

## Design history — the main decisions

- **"What we'd build AND how" is the core value.** An earlier draft made the work lens
  *avoid* the "how" — wrong. The user wants the approach mapped, especially the build-vs-reuse
  choices with their tradeoffs. "How" was bounded to approach-level (mechanism, building
  block, touch points), not file-by-file implementation, which stays in the later step.
- **Following the feature is the method.** The skill walks the feature end-to-end to find
  touch points and decisions nobody asked (the "saved addresses → block them?" kind). That
  walk is what separates this from a generic checklist.
- **Choices = options + tradeoffs + a recommended pick, never picked on its own.** Matches the
  user's standing preference to surface alternatives with tradeoffs rather than quietly
  choosing a path.
- **T-shirt size + confidence, never a bare number.** Sizes XS/S/M/L; confidence tied to open
  unknowns and unsettled choices. Every size ships with the *why* and the lever. An **L**
  signals the feature isn't actually small — split it or escalate.
- **Guided walk, one part at a time.** The skill leads the user through the feature part by
  part; for each part the user decides, states an approach, or asks to explore. This replaced
  an earlier "fill all lenses high-level, then drill on request" design — the user wanted the
  skill to guide them step by step, settling each part before the size.
- **Exploration is a separate agent, only when asked.** When the user picks Explore on a
  part, dispatch a separate agent with one focused question; it reads code and reports back;
  the user decides. The skill does not read the codebase in its own context.
- **One flat file, descriptively named.** No folder promotion — a small feature is one scope.
  If it turns out large, that's an **L** + a split suggestion, not a folder.
- **No tool/company specifics baked in.** The reuse-vs-custom reasoning is stated generically;
  concrete mechanism names come from the codebase at run time, not the spec. The later handoff
  is to "a build-planning step", deliberately unnamed.

## Deliberately out of scope

- **The detailed build plan** — task order, file-by-file changes, code. A separate, later
  step (deliberately unnamed in the spec).
- **Bugs / complaints** — `/ticket-triage`.
- **Large epics** — an L result points to splitting or escalating, not deeper scoping here.
- **Auto-handoff** — always offered, never forced.

## Pitfalls / don'ts

- **Don't drop below approach-level into implementation.** Mechanism + touch points, not
  steps/files/code. If you're writing the build, you've gone too far.
- **Don't pick a side at a choice on your own.** Options + tradeoffs + a pick; the user calls
  it.
- **Don't give a bare size.** Always size + confidence + why + lever.
- **Don't present a Low-confidence size as settled.** Open unknowns/choices mean "resolve
  first".
- **Don't fill an unknown with a silent assumption.** Tag it `#assumption` and flag what rests
  on it, or ask.
- **Don't read the repo in your own context.** Explore only when the user asks, through a
  separate agent with one focused question.
- **Don't jump ahead.** Settle the current part before the next; size only at the end.
- **Don't scope a large feature as small.** Size it L and point to the splits.
- **Don't bake in tool or company names.** Keep the spec generic; names come from the code.
