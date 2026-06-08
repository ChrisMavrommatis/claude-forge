---
name: feature-scope
description: Scope and size a small feature before you build it. It guides you through the feature one part at a time — for each part you decide the approach, tell the skill how you plan to build it, or have it send a separate agent to explore the code, then you decide. Build-vs-reuse choices are shown as options with tradeoffs and a recommended pick. Once every part is settled, it gives a size and a confidence. Read-only; explores the codebase only when you ask. Use when someone asks for a small feature and you need to understand the work before quoting or planning. Examples — `/feature-scope`, `/feature-scope <name>` to resume.
---

# Feature Scope

You bring a small feature someone asked for, like "add zipcode validation". Before you
quote it or plan the build, this skill works it out: what to build, how to approach each
part, what is unclear, what could go wrong, and how big it is. It does not write code. It
produces a scope you can quote from or hand to a build plan.

This is the step before the detailed build plan. This answers *what, how, and how big*.
The build plan answers *the exact steps*.

## In plain terms

The skill helps you understand the whole job before you commit to it. The common mistake
it prevents: someone says "it's small, just validate the zipcode", you quote it, and then
you find there is no place to import the data, validation has to run in three places, and
checkout has saved addresses nobody thought about. This skill finds those things first, so
the size you give is based on facts, not hope.

### Goals — what "done" looks like

By the end of a scope you have answers to all five:

1. **The ask is clear** — one plain sentence everyone agrees on.
2. **The build is mapped** — the parts to build, and for each, how (reuse what exists or
   build new), with the options and tradeoffs of each choice and a recommended pick.
3. **The unknowns are listed** — every unknown or undecided thing written down as a
   question, not guessed at silently.
4. **The decisions are recorded** — the choices and questions you have answered, written
   down so they don't reopen.
5. **A size with a confidence** — XS, S, M, or L, plus how sure you are and what would make
   you surer.

### Procedure — the steps it follows

The skill guides you through the feature one part at a time. It leads; you decide at each
part.

1. **Name it.** Restate the request in one sentence. Agree on a name, create the scope file.
2. **Pin the ask.** Agree the one-line ask before going further.
3. **List the parts.** Follow the feature through the system to break it into the parts that
   each need an implementation decision. Show the list and confirm it. These parts are the
   steps you will walk.
4. **Walk each part.** Go through the parts one at a time. For each, show the part and any
   reuse-vs-build choice, then ask how to settle it. There are three ways:
   - **Decide** — you pick the approach, or confirm the recommended pick.
   - **Tell me your approach** — you say how you plan to build it; the skill records it.
   - **Explore** — the skill sends a separate agent to investigate one question, reports the
     findings back, and you decide.
   Record the result, then move to the next part. Don't jump ahead.
5. **Size it.** When every part is settled, give the size, confidence, and the reason. A part
   settled by a decision or by exploration raises confidence; a part left high-level or
   assumed lowers it. If it is big (L), say so and suggest splitting.
6. **Hand off.** Offer to pass the scope to a build plan, or you quote it or shelve it. Your
   call.

Three rules run through all of it: keep what is known separate from what is guessed (every
known is tagged with where it came from); never pick a side at a choice on your own (show
the options, recommend one, you decide); and confidence only goes up by settling parts,
never by claiming it.

The rest of this file is the detail behind these steps — the lenses, the guided walk, the
guardrails, and the sizing table.

## When to use

- Someone asks for a small feature and you need to understand the work and approach first.
- You are about to quote or estimate and want the choices, touch points, and unknowns laid
  out.
- You want a worked-out scope to hand to a build plan so it starts from solid ground.

## When NOT to use

- It is a bug or a vague complaint, not a new feature → that is `/ticket-triage`.
- You already know exactly what to build, how, and how big → skip scoping, plan the build.
- It is clearly a large, multi-team job → too big for this; this is for small features.

## How to invoke

```
/feature-scope [name]
```

- **Bare, with the feature request** → start a NEW scope. (It also tends to start when you
  say "the client wants…" or "we need to add…". The slash command is the reliable way.)
- **`/feature-scope <name>`** → resume an existing scope: find its file in `.plans/` and
  pick up where it left off (re-print the status block first). If no file matches that
  name, start a new scope under it.

## The lenses

A scope looks at the feature through six lenses. They are the record — the guided walk fills
them as you settle each part. They are not the steps you walk (the parts are); they are how
the scope is written down.

| Lens | Icon | The question it answers |
|------|------|-------------------------|
| Ask      | 🎯 | What does the client want? (one line) |
| Build    | 🧩 | What would we build, and how — which approach, where does it connect? |
| Unknowns | 🕳️ | What is missing, unknown, or undecided? |
| Decided  | ☑️ | Which choices and decisions have we made? |
| Risks    | ⚠️ | What could go wrong — technically or in scope? |
| Size     | 📏 | How big is it, and how sure are we? |

Per-lens detail, including how deep to go and when to read code, is in
[lenses.md](lenses.md). Read it on start.

## The main technique — follow the feature through the system

You fill **Build** and **Unknowns** by following the feature end to end: where the data
comes in, where it is used, what existing thing could carry it, what would have to change,
and what breaks. Each thing the feature touches is one of:

- **a part to build** (with an approach) → Build, or
- **a choice it forces** → Unknowns until answered, then Decided.

The zipcode example, followed through:

- *Importing the set* → **a choice**: reuse an existing import, or build a new one. They
  differ — for example the existing one may never remove entries deleted at the source, a
  new one can. That difference is part of the scope, not a footnote.
- *Validating* → likely a validation service plus an attribute; find **where** it must run
  (every place an address is entered).
- *Checkout has saved addresses* → a **decision** comes up: do we block an invalid saved
  one? Nobody asked it; following the feature found it.

That walk — choice, touch point, decision — is how the skill finds the parts. Each part it
finds becomes a step you walk in the guided walk below.

## What "how" means here

"How" is the **approach**: which mechanism (reuse or build new), which building block (a
service, an attribute), and **where it connects**. It is **not** file-by-file work, step
order, or code. That detailed build plan is a separate step that comes after this. This
skill stops at the approach and the size.

## The guided walk

This is how the skill runs. It leads; the user settles each part.

1. **Setup.** Pin the one-line ask. Then follow the feature through the system and list the
   parts that each need an implementation decision. Show the list and confirm it. Don't read
   code in depth here — just enough to name the parts.
2. **Walk one part at a time.** For each part in turn:
   - Show the part. If there is a reuse-vs-build choice, show the options with tradeoffs and
     a recommended pick.
   - Ask how the user wants to settle it. Offer three ways:
     - **Decide** — the user picks the approach, or confirms the recommended pick.
     - **Tell me your approach** — the user says how they plan to build it; record it.
     - **Explore** — send a separate agent to investigate one question (for example, "does an
       import that removes stale rows already exist?"). It reports back. Then the user
       decides.
   - Record the result in Build and Decided. Note any new unknown or risk it surfaced.
   - Move to the next part. Don't jump ahead.
3. **Depth is per part.** A part can be settled high-level (a quick decision) or in detail
   (after exploring). The user chooses per part. You don't have to treat every part the same.
4. **Size at the end.** Once every part is settled, size the whole feature. How each part was
   settled sets the confidence (see The size).

### Exploration uses a separate agent

- When the user picks **Explore**, dispatch a separate agent to do the discovery and report
  back. Don't read through the codebase in your own context.
- Give the agent one focused question. It reads code, returns what it found with sources, and
  flags what it could not determine.
- If the project ships a dedicated exploration agent, use it; otherwise use a general
  exploration agent. Stay read-only.
- Bring the findings to the user and let them decide. The skill does not decide for them.

## Guardrails

These come before the urge to sound confident. Follow them.

1. **Known and guessed are different. Don't mix them.**
   - A **known** has a source (the request, a user answer, the code, a repo pattern). It can
     count in the approach and the size.
   - A **guess** is something you had to assume. Tag it `#assumption`, and say which
     approach or size depends on it.
   - A claim with **no source is not a known** — it is a guess. No exceptions.
2. **The request is a want, not a spec.** "Validate the zipcode" tells you what someone
   wants, not what it involves. Treat it as `#request` — the weakest source — until
   something real backs up the details.
3. **At each choice, show the options with tradeoffs, then recommend. Don't pick on your
   own.** Reuse-vs-build and which-mechanism are real decisions with consequences. Show each
   option, what it costs, what it risks, what it leaves unsolved; recommend one and say why;
   let the user choose.
4. **Confidence depends on unknowns.** Many open unknowns or unmade choices → Low confidence
   → say "answer these first." You don't reach High confidence with open choices; you reach
   it by closing them. Don't present a Low-confidence size as settled.
5. **Don't pad and don't lowball.** Size the real work, including the likely cost of the
   chosen approach and the open unknowns — but mark which part is known and which is a hedge
   against what you don't know.
6. **When unsure, ask or write it down — don't invent.** A gap is a 🕳️ Unknown or a tagged
   `#assumption`, never a silent blank that quietly grows or shrinks the size.
7. **Walk one part at a time. Don't jump ahead.** Settle the current part before moving on.
   Don't size the feature until every part is settled or explicitly left high-level.
8. **Explore only when the user asks, through a separate agent.** Don't read the codebase in
   your own context. When the user picks Explore, send a separate agent with one focused
   question; it reports back; the user decides.
9. **Read-only.** This skill never edits code. It reads code and patterns (through the explore
   agent) to back up the scope and writes only to `.plans`. Building comes later, not here.

## Knowns and guesses — source tags

Every known says where it came from. More tags means more sources, which means more weight.
Tags stack, separated by spaces (for example `#code #pattern`).

| Tag | The detail came from… |
|-----|-----------------------|
| `#code`       | the source code |
| `#pattern`    | an existing convention or precedent in this codebase |
| `#user`       | a confirmed answer from the user or PM |
| `#request`    | the feature request itself (weakest — a want, not checked) |
| `#assumption` | nothing yet — a guess you had to make |

A detail that drives the 🧩 Build approach or the 📏 Size must carry at least one of the top
four tags. `#request`-only or `#assumption` details are hedges, not knowns — mark them.

## The status block

After the first pass, and whenever the picture changes, print a short status block. Keep
lines tight. Unknowns are questions. Choices show the options, the tradeoff, and the pick.
This block is the at-a-glance view; it is the same thing you re-print on resume.

```
📍 feature-scope · zipcode-validation

🎯 Ask
- validate zipcode on address entry  #request

🧩 Build — what & how
- import the zipcode set  ← CHOICE:
    · reuse existing import — simple, but never removes deleted entries (stale set)
    · build a new importer — handles removals, more work
    → pick: reuse, for a zipcode-only set; note the no-delete gap  #pattern
- validation service + attribute, run wherever an address is entered  #code
- block invalid saved addresses at checkout  (see Decided)

🕳️ Unknowns
- which countries' zipcodes? one or many?  (changes set + validation)
- how many address-entry paths are there?  (could be more than one)
- fail open or fail closed if the set is unavailable?

☑️ Decided
- block invalid saved addresses at checkout → yes  #user

⚠️ Risks
- the import choice drives the size, and reuse vs build is still open  #assumption
- existing submit may have no async-validation hook  #code

📏 Size
- M · Low confidence — import choice open + 3 unknowns
  → answer the import choice and the country scope and this likely drops to S
```

- **📍 line** — the skill and the scope name.
- **🎯 / 🧩 / ⚠️** — knowns carry source tags; choices show options, tradeoff, and pick.
- **🧩 Build** — each part shows how it was settled: a decided pick, the user's stated
  approach, or a finding from exploration. A part not yet reached stays an open choice or a
  `#assumption`.
- **🕳️ lines** — questions; these and unsettled parts drive confidence.
- **☑️ Decided** — choices and decisions once made, kept short.
- **📏 Size** — size, confidence, the one-line reason, and what would move it.

## The size — T-shirt plus confidence

**Size** is the rough effort, not a promise:

| Size | Roughly means |
|------|---------------|
| **XS** | one place, known pattern, no real unknowns or choices |
| **S**  | a few places, a known approach, minor unknowns |
| **M**  | several parts, a reuse-vs-build choice, or new data; real unknowns remain |
| **L**  | spans many areas with real unknowns — **probably not actually small** |

**Confidence** is how much to trust the size, set by how the parts were settled:

| Confidence | When |
|------------|------|
| **High**   | every part settled by a decision or exploration; backed by `#code` / `#user` / `#pattern` |
| **Medium** | most parts settled, but some left high-level or resting on an `#assumption` |
| **Low**    | parts still open, or settled only by guesses; the size is a guess — **settle them before quoting** |

**If, once the parts are listed, the feature is clearly XS with nothing to settle**, say so
and offer to go straight to building or quoting instead of walking each part.

**If it is L**, say so plainly: "this is not small — consider splitting it into separate
features, or take it into a full build plan." Don't scope a large thing as if it were small.

**Always give the size with what would move it.** Not a bare size. Give the size, the
confidence, the reason, and the lever: "M / Low — the import choice is open and three
unknowns remain; answer the choice and the country scope and this likely drops to S."

## The record in `.plans`

A scope is one flat file with a descriptive name. Use the feature's name, not a ticket code.

```
.plans/zipcode-validation.md
```

- **On start:** propose a name, get the user's ok, then create `.plans/<name>.md` from
  [templates/scope.md](templates/scope.md), drop the raw request in untouched, run the
  first pass.
- **Naming:** propose first, confirm, then create.

### When the file gets written

- **Written right away, no asking** — every unknown, every choice (options plus tradeoff),
  every decision, every known (a detail plus its source tag), and the size and confidence
  whenever they change. Losing one means re-scoping. Refresh the status block when they
  change.
- **Written on a trigger** — the fuller text (the approach detail, the risk reasoning): when
  the user pauses or exits, asks to `save` or `flush`, or you offer at a natural break ("want
  me to save the scope before you go?").

## Handoff

Scoping ends with the map and a size. It does not build. When the user is happy with the
scope, the next step is a detailed build plan or building it directly. Offer it, don't force
it:

> "Scope looks solid — S / High confidence, import choice set to reuse. Want to take this
> into a build plan, or are you quoting it first?"

The scope file is the handoff: a build plan reads `.plans/<name>.md` as its starting brief.
The user may also quote it, defer it, or drop the feature.

## Constraints

- **Plain language always.** Short, clear sentences. No flourish. Less is more.
- **Read-only.** Reads code and patterns (through the explore agent) to back up the scope;
  writes only to `.plans`. Never edits.
- **Guided, one part at a time.** The user settles each part — by deciding, stating an
  approach, or asking to explore — before the size. Don't jump ahead.
- **Explore through a separate agent, only when asked.** Don't read the codebase in your own
  context.
- **"How" is the approach**, never file-by-file work.
- **Honest sizing.** Never a bare size; always size, confidence, reason, and the lever.
- **Choices get options, tradeoffs, and a pick** — recommend, don't decide for the user.
- **No tool or company names baked in.** "Reuse an existing mechanism vs build new" is said
  in general terms; concrete names come from the codebase at run time, not this file.

## Out of scope

- **The detailed build plan** — step order, file-by-file changes, code. A separate step that
  comes after this.
- **Bugs and vague complaints** — that is `/ticket-triage`.
- **Large multi-team jobs** — this is for small features; an L result means split or
  escalate, not keep scoping here.
