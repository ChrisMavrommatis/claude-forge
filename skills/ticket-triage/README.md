# ticket-triage

A ticket comes in. Instead of letting Claude jump to a solution — inventing,
hallucinating, assuming — this skill works through it in a fixed order:

1. **RAW** — the ticket's words, untouched.
2. **MEANING** — what it could mean (a lens, not a conclusion).
3. **PROBLEM** — the real problem underneath.
4. **EXPLAIN** — why it happens, as far as the evidence goes.
5. **SOLUTIONS** — options + tradeoffs, only on your explicit go.

Claude asks before each step and never jumps to solutions on its own. Facts and guesses
are kept separate — every fact carries a source tag (`#code`, `#system`, `#log`,
`#data`, `#user`, `#ticket`), and a guess stays a guess until a source proves it or you
confirm it.

It works read-only — reading code, system, and logs to gather evidence, writing only to
`.plans` — until you explicitly say "now fix that".

## Use it

```
/ticket-triage            # paste the ticket text → start a new triage
/ticket-triage <name>     # resume an existing ticket from .plans/
```

It also tends to start when you say "I have this ticket". The slash command is the
reliable trigger.

## The record

A ticket starts as one flat, descriptively named file in `.plans/`. If it grows several
findings, Claude offers to promote it to a folder — `README.md` as the master track
plus one ordered file per finding (`1-…`, `2-…`). Promotion is always your call.

## File layout

```text
ticket-triage/
├── SKILL.md            core spec — the fixed-order triage flow
├── steps.md            the five steps in detail (RAW → MEANING → PROBLEM → EXPLAIN → SOLUTIONS)
├── templates/
│   ├── README.md       templates overview
│   ├── ticket.md       the flat ticket record written to .plans/
│   └── finding.md      one finding file inside a promoted ticket folder
├── AGENT.md            orientation for an agent reading this skill cold
└── README.md           you are here
```

## Install

```bash
# Linux / Mac
cp -r skills/ticket-triage ~/.claude/skills/

# Windows (PowerShell)
Copy-Item -Recurse skills\ticket-triage $env:USERPROFILE\.claude\skills\
```

See the parent [README](../../README.md) for repo-level context.

## Not this skill

When there's no clear solution, or the problem is multi-layered and needs debug
instrumentation to uncover — that's a separate (future) discovery skill.
