# ticket-triage — agent brief

Read this first if you're picking up this skill cold. It orients you to what this is,
how it works, and the calls behind it.

## What this skill is for

Triage of an incoming ticket in a fixed order. The default Claude behaviour — paste a
ticket, invent a solution, hallucinate, assume — is what this prevents. The skill
follows a fixed five-step order (RAW → MEANING → PROBLEM → EXPLAIN → SOLUTIONS), gated
step by step, with a hard stop before solutions.

## Mental model

- **The skill is prompt-based.** No compiled code. The Markdown IS the implementation.
  `SKILL.md` is the always-loaded core; `steps.md` and the `templates/` files are read
  on demand (steps.md on start, templates when creating files).
- **Two artefacts per run:** the conversation (where the thinking happens) and the
  `.plans` file (the durable record). The file's **Status block** is the at-a-glance
  view; the prose below it is the full record.
- **Facts vs. possibilities is the core rule.** A fact is confirmed and source-tagged; a
  possibility is a labelled guess. The skill exists to stop guesses passing as facts.
  Source tags: `#code #system #log #data #user #ticket` (last is weakest).
- **Read-only by default.** Reads code/system/logs for evidence; writes only `.plans`.
  Crosses into editing code only on the user's explicit "now fix that".

## Where to look for what

| I want to change                         | Edit                                  |
| ---------------------------------------- | ------------------------------------- |
| Invocation / triggers / resume           | `SKILL.md` → How to invoke            |
| The guardrails (anti-hallucination core) | `SKILL.md` → Guardrails               |
| Source-tag taxonomy                      | `SKILL.md` → Facts vs. possibilities  |
| The at-a-glance summary shape / icons     | `SKILL.md` → The at-a-glance summary  |
| `.plans` layout / naming / promotion      | `SKILL.md` → The record in `.plans`   |
| Trail timing (live vs. flush)            | `SKILL.md` → When the file gets written |
| Per-step behaviour, do/don't, gates       | `steps.md`                            |
| The flat ticket-file shape                | `templates/ticket.md`                 |
| The per-finding file shape               | `templates/finding.md`                |

## Design history — the big calls

- **Five gated steps, hard stop before solutions.** The point is order. Soft gates
  everywhere except SOLUTIONS, which needs an explicit go. Claude may *offer* to explore
  but never goes ahead silently.
- **Facts vs. possibilities with mandatory source tags.** The observed failure was
  Claude floating four theories where one is right and three are noise. Rule: a claim
  with no source is a ❓ Maybe, never a ✅ Fact. The ticket text itself is `#ticket` —
  the weakest tag, a claim not a verified fact.
- **Short, icon-led summary; RAW never shown in it.** The user wanted a quick glance.
  RAW lives in the file only. Maybe / Open lines are questions.
- **Record grows with the ticket.** Starts as one flat descriptively-named `.md`;
  promotes to a folder (`README.md` + ordered `N-name.md` findings) only when findings
  multiply — and only on user approval. Descriptive names, never ticket codes.
- **Trail timing is a mix leaning live.** Claims and evidence are written the moment
  they appear (losing one means redoing investigation). Fuller prose is saved on
  pause/exit, on request, or on Claude's offer.
- **Triage ends at options.** After SOLUTIONS the user decides — small fix, plan, or
  nothing. No forced handoff to a planning/impl skill.

## Deliberately out of scope

- **The debug / discovery process** for when no solution is found or the problem is
  multi-layered — a separate future skill, by the user's explicit decision.
- **Pulling the ticket itself** (from a Wrike/ADO link). For now the user pastes the
  text. Could be added later behind the resume/start invocation.
- **Auto-promotion to a folder.** Always user-approved; never silent.

## Pitfalls / don'ts

- **Don't propose solutions early.** If you catch yourself doing it, stop and return to
  the current step. This is the #1 failure the skill exists to prevent.
- **Don't promote a guess to a fact** without a source or user confirmation.
- **Don't show RAW in the at-a-glance summary** — it belongs in the file.
- **Don't dig silently.** One focused probe, then report back, unless told to continue.
- **Don't edit project code** until the user explicitly says fix it.
