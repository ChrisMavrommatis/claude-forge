# feature-scope — agent brief

Read this first if you're picking up this skill cold. It tells you what this is, how it
works, and the decisions behind it.

## What this skill is for

Discovering how you'd build a *small new feature*, whether it's feasible in this codebase,
and what the paths and tradeoffs are — then sizing it, before any commitment to build. The
default Claude behaviour — hear "add zipcode validation", agree it's small, start coding — is
what this prevents. The skill makes you work out **how we'd build it and whether it's
feasible here** (approach-level, sourced from a read-only code pass, with build-vs-reuse
choices written out as options + tradeoffs), **follow it through the system** to find touch
points and decisions, surface the unknowns and risks, and put a defensible T-shirt size on
it. It is the thinking *before* the detailed build plan: **feature-scope = how, feasible,
how big; the build plan = the exact steps.**

## Mental model

- **The skill is prompt-based.** No compiled code. The Markdown is the implementation.
  `SKILL.md` is the always-loaded core; `lenses.md` is read on start; `templates/` is read
  only when creating the scope file.
- **Six lenses are the record, not the steps.** 🎯 Ask · 🧩 Build · 🕳️ Unknowns · ☑️ Decided ·
  ⚠️ Risks · 📏 Size. The guided walk fills them as the user settles each part. The parts are
  the steps; the lenses are how the scope is written down.
- **Discovery pass at setup, offered not automatic.** Before listing parts, the skill offers
  one read-only code pass with a broad orienting question so the parts and choices come from
  the codebase, not just the request and memory. It runs only on the user's ok, and is skipped
  for a trivial XS. This is the biggest lever; without it the skill rubber-stamps the human's
  plan.
- **It is a guided walk, one part at a time.** Setup pins the ask, runs the discovery pass,
  and lists the parts; then the user settles each part in turn — by deciding, stating an
  approach, or asking to explore. When the user states an approach, the skill first checks the
  code for a reuse path or a different seam and surfaces it as a choice before recording. Each
  part also gets a feasibility check. Don't jump ahead; size only when every part is settled.
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
- **Unknowns (and unsettled choices) drive confidence; a hard blocker caps it.** Size
  confidence (Low/Med/High) depends on how many unknowns and choices are still open. Closing
  one should visibly move the size — say so. An unresolved hard blocker (a required extension
  point that may not exist, a framework or permission constraint) forces Low confidence
  regardless of how many parts are settled — the feasibility gate.
- **Read-only.** Reads code/patterns to back up the map; writes only `.plans`. Never edits,
  never builds.

## Where to look for what

| I want to change                          | Edit                                       |
| ----------------------------------------- | ------------------------------------------ |
| Invocation / triggers / resume             | `SKILL.md` → How to invoke                 |
| The guardrails                              | `SKILL.md` → Guardrails                    |
| The follow-the-feature technique            | `SKILL.md` → The main technique            |
| The estimate-mover checklist                | `SKILL.md` → The estimate-mover checklist  |
| The discovery pass (offer / run)            | `SKILL.md` → The discovery pass            |
| The feasibility question and gate           | `SKILL.md` → Guardrails, The size          |
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
- **Discovery pass at setup — offer-and-confirm, not silent default-on.** An earlier design
  told the setup step *not* to read code ("just enough to name the parts"), so the parts,
  choices, and tradeoffs were produced from the request and the human's memory before any code
  was read — the skill rubber-stamped the human's plan. Now it offers one read-only pass with
  a broad orienting question and runs it on the user's ok, feeding the findings into the parts
  and choices. It is offered, not fired automatically: an auto-firing subagent takes the
  control gate from the human and is the reflexive fan-out the guide warns against. Skipped for
  a trivial XS. The shape is one broad pass + focused per-part explores, never a
  read-everything fan-out.
- **A stated approach triggers an alternatives check.** "Tell me your approach" used to just
  record the human's plan. Now, before recording, the skill checks the code for a reuse path
  or a different seam the human didn't mention and surfaces it as a choice — matching the
  standing preference to surface alternatives with tradeoffs rather than accept one path.
- **Feasibility is a first-class question and a gate.** The skill asks per part whether
  anything in the code would block the approach, and an unresolved hard blocker forces Low
  confidence regardless of how many parts are settled. Without this the size could read High
  for an approach that may not be buildable here.
- **Following the feature is the method, with a repeatable checklist.** The skill walks the
  feature end-to-end to find touch points and decisions nobody asked (the "saved addresses →
  block them?" kind), and runs a generic estimate-mover checklist (entry points, data model,
  permissions, async, public contract, tests, config, i18n) so coverage repeats across
  features instead of resting on one worked example. That walk is what separates this from a
  generic checklist.
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
- **The code is read through a separate agent, offered before it runs.** The discovery pass at
  setup and each per-part Explore both dispatch a separate agent (broad orienting question for
  discovery, one focused question for Explore); it reads code and reports back; the user
  decides. Both are offered and run on the user's ok. The skill does not read the codebase in
  its own context, and does not fan out to read everything.
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
- **Don't read the repo in your own context.** The discovery pass and every Explore run
  through a separate agent, and both are offered before they run. Don't fan out to read
  everything — one broad discovery pass, then focused explores.
- **Don't just record a stated approach.** Check the code for a reuse path or a better seam
  first and surface it as a choice.
- **Don't let a hard blocker read as settled.** An unresolved feasibility blocker forces Low
  confidence.
- **Don't jump ahead.** Settle the current part before the next; size only at the end.
- **Don't scope a large feature as small.** Size it L and point to the splits.
- **Don't bake in tool or company names.** Keep the spec generic; names come from the code.
