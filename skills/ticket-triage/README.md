# ticket-triage

A ticket comes in. Instead of letting Claude race to a solution — inventing,
hallucinating, assuming — this skill walks a fixed path and holds the order:

1. **RAW** — the ticket's words, untouched.
2. **MEANING** — what it could mean (a lens, not a conclusion).
3. **PROBLEM** — the real problem underneath.
4. **EXPLAIN** — why it happens, as far as the evidence goes.
5. **SOLUTIONS** — options + tradeoffs, only on your explicit go.

Claude asks before each step and never jumps to solutions on its own. Facts and
guesses are kept strictly apart — every fact carries a source tag (`#code`, `#system`,
`#log`, `#data`, `#user`, `#ticket`), and a guess stays a guess until a source proves
it or you confirm it.

It works read-only — reading code, system, and logs to gather evidence, writing only to
`.plans` — until you explicitly say "now fix that".

## Use it

```
/ticket-triage            # paste the ticket text → start a new triage
/ticket-triage <name>     # resume an existing ticket from .plans/
```

It also tends to auto-fire when you say "I have this ticket". The slash command is the
reliable trigger.

## The record

A ticket starts as one flat, descriptively named file in `.plans/`. If it grows several
findings, Claude offers to promote it to a folder — `README.md` as the master track
plus one ordered file per finding (`1-…`, `2-…`). Promotion is always your call.

## Not this skill

When there's no clear solution or the problem is multi-layered and needs debug
instrumentation to uncover — that's a separate (future) discovery skill.
