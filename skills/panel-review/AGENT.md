# panel-review — agent brief

Read this first if you're picking up this skill cold. It orients you to what this is, how it works, what was tried and rejected, and where to look for what.

## What this skill is for

Multi-persona code review. The orchestrator dispatches several role-based sub-agents (Dev, Tech Lead, QA, PM, Client, plus optional security / devops / junior / accessibility / performance) in parallel against the same diff, then consolidates their findings into one verdict (SHIP / HOLD / REJECT). The strongest signal is **convergence** — anything 2+ personas independently flag is almost certainly real. Solo `[BLOCK]`-severity findings from a specialist also surface in the summary, marked with `*`.

## Mental model

- **The orchestrator** is the Claude agent running this skill — it parses the target, dispatches personas, waits for results, consolidates, and prints.
- **Personas** are sub-agents dispatched in parallel. Each gets its own `personas/<name>.md` injected verbatim plus the resolved target and the mandatory output format. They return structured findings.
- **The skill is prompt-based.** There's no compiled code. The Markdown content IS the implementation. `SKILL.md` is the always-loaded core; sibling files (`details.md`, `failure.md`, `veto.md`, `templates/persona.md`) are lazy-loaded by trigger condition.

## Where to look for what

| I want to change                              | Edit                                                       |
| --------------------------------------------- | ---------------------------------------------------------- |
| Invocation flags / target types               | `SKILL.md` → How to invoke                                 |
| The execution flow                            | `SKILL.md` → How to execute                                |
| Size-guard thresholds or counting             | `SKILL.md` → Size guard                                    |
| The persona output contract                   | `SKILL.md` → Mandatory output format                       |
| Summary banner / verdict table / TOP rules    | `SKILL.md` → Console output                                |
| A specific persona's lens, look-fors, voice   | `personas/<name>.md`                                       |
| Per-persona card layout / drill-in            | `details.md`                                               |
| Failure rendering / all-failed exit           | `failure.md`                                               |
| Veto mechanism / override flow                | `veto.md`                                                  |
| Authoring a new persona                       | `templates/persona.md`                                     |

## Design history — the big calls

- **Lazy-load architecture, not monolithic `SKILL.md`.** Only the core spec loads every run. Optional behaviour (per-persona details, failure rendering, veto, persona authoring) lives in sibling files loaded by trigger condition. Keeps the always-on context small.
- **Convergence + solo `[BLOCK*]` in TOP.** Original design was convergence-only, but that hid critical solo specialist findings (e.g. a hardcoded secret from security alone). Fix: solo `[BLOCK]` items make TOP, marked with `*`. Solo `[DEFER]` / `[INFO]` stay in cards.
- **Separate `Tagline` field for the verdict table.** Personas write one-sentence verdict reasons; those don't fit in a 37-char table column. Solution: personas produce a separate `Tagline` (≤37 chars) for the table cell, distinct from the full verdict reason that lives in the card.
- **One canonical verdict rule.** Originally duplicated in SKILL.md step 7 and `veto.md`. Reconciled: SKILL.md is canonical; `veto.md` just describes how vetos hook into the REJECT branch and the `HOLD†` acknowledgment state.
- **Veto is per-persona opt-in via frontmatter (`veto: true`).** No persona is veto-eligible by default. `security` ships with `veto: true` but is `tier: optional` — must be explicitly added to the panel for veto behaviour to fire. Keeps the skill portable for orgs whose gatekeepers differ.
- **`security` is the only veto-eligible built-in.** QA was considered but rejected — QA's REJECT is usually about test-process gaps, not absolute defects; a HOLD is the right weight there.
- **Unicode box-drawing over plain ASCII.** Original plan called for ASCII (universal terminal compat). Switched to Unicode for visual quality during design — the loss of legacy-terminal support is acceptable.
- **Card width is a 64-char target, not a hard contract.** LLMs miscount characters occasionally; padding may drift 1-2 chars on edge cases. Documented as a known limit, not a spec violation.

## What's complete

- Eight-step execute flow with size guard before dispatch.
- Default model is Sonnet (Opus for `--explain`); `--model=<name>` overrides.
- Summary always prints (banner + verdict table + TOP). Per-persona cards on request or `--details`.
- Drill-in via `--explain <persona>` for deeper single-persona analysis.
- Severity tagging (`[BLOCK]` / `[DEFER]` / `[INFO]`) with `*` modifier for solo specialist findings.
- Convergence detection with most-severe-wins on merge conflicts.
- Veto mechanism with criteria-based escalation, written-acknowledgment override, and `HOLD†` state.
- Failure handling: individual failures don't kill the run; all-failed aborts cleanly.
- Output schema validation: malformed persona output → FAILED.
- Ten personas (5 required, 5 optional including accessibility + performance).

## Deliberately out of scope

- **HTML report mode.** Console output is good enough. If reintroduced, the spec lives in git history.
- **Path filter inside a target.** Niche. `range:` and `feature:` cover the common shapes.
- **Per-persona lens-drift guard.** Subsumed by the per-persona Voice rule + the global plain-language constraint.
- **Saved review history.** Not worth a schema until 20+ real-usage runs reveal a pattern worth indexing.
- **Auto-posting to PR comments.** Build only after the console workflow is proven and the right post-format is obvious.
- **Custom verdict labels beyond SHIP / HOLD / REJECT.** No demand.

## Common edits — how to extend

- **Add a persona:** drop a file in `personas/`. See `templates/persona.md` for the shape and an example.
- **Make a persona veto-eligible:** add `veto: true` + a `Veto criteria` section + an `Emit a veto:` instruction. See `personas/security.md` as a working example.
- **Add a new optional feature with its own spec:** create a sibling file (e.g. `your-feature.md`), reference it in the "Optional features" table of `SKILL.md`, gate the load on a clear trigger condition (a flag, a state).
- **Change the verdict rule:** edit `SKILL.md` step 7 (the only canonical source). Update `veto.md`'s acknowledgment branch if vetos are affected.
- **Change a persona's voice:** edit the `Voice rule:` line at the end of `personas/<name>.md`. Don't fork the file.

## Pitfalls / don'ts

- **Don't bloat `SKILL.md`.** The lazy-load architecture exists for a reason. Anything optional or trigger-conditional belongs in a sibling file.
- **Don't duplicate the verdict rule.** It's canonical in `SKILL.md` step 7. `veto.md` references it; nothing else restates it.
- **Don't add a verdict tier beyond SHIP / HOLD / REJECT** without thinking through the veto interaction, the acknowledged-veto state, and what the verdict table shows.
- **Don't violate "plain language always."** Personas write findings in jargon-free English; the constraint applies to every text field they produce.
- **Don't make personas mutually aware.** Each persona reviews independently with no knowledge of other personas' findings. Convergence is computed by the orchestrator post-dispatch, never by personas.
- **Don't add per-persona model overrides.** One model per run, set by `--model`. Per-persona model selection adds complexity that hasn't earned its place.
- **Don't auto-edit code from the skill.** Read-only is a hard constraint.
