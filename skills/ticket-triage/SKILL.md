---
name: ticket-triage
description: Triage an incoming ticket in a fixed order — take the raw request, work out what it could mean, find and explain the real problem, and only then weigh solutions. Stops Claude jumping to solutions, inventing, or assuming. Keeps facts and guesses separate; every fact is backed by a source. Read-only (writes only to `.plans`) until you explicitly say fix it. Use when you paste a Wrike / Jira / ADO ticket or say "I have this ticket". Examples — `/ticket-triage`, `/ticket-triage <name>` to resume.
---

# Ticket Triage

A ticket comes in. This skill works through it in a fixed order: take the raw words →
work out what they could mean → find the real problem → explain it → and **only then**
weigh solutions. It keeps that order, keeps facts separate from guesses, and never
invents.

## What this is for

The mistake this prevents: you paste a ticket and Claude invents a solution, makes
things up, and assumes — and you have to argue it back down. This skill makes Claude
slow down, stay on evidence, and ask before it acts.

## When to use

- A Wrike / Jira / ADO ticket comes in and you want to understand it before touching code.
- A vague or messy request where the real problem isn't obvious yet.
- Any case where Claude has solved the wrong problem before.

## When NOT to use

- You already know the exact fix and just want it done — skip triage, fix it.
- A plain "how does X work?" question — that's exploration, not triage.

## How to invoke

```
/ticket-triage [name]
```

- **Bare + pasted ticket text** → start a NEW triage. It also tends to start when you
  say "I have this ticket" or paste a ticket, but the slash command is the reliable
  trigger.
- **`/ticket-triage <name>`** → RESUME an existing ticket: find its file in `.plans/`
  and pick up where it left off (re-print the at-a-glance summary first).

## The flow

Five steps, walked in order. Full detail in [steps.md](steps.md) — read it on start.

| Step | Name | What happens |
|------|------|--------------|
| 1 | RAW | Restate the ticket's words untouched. No interpretation. |
| 2 | MEANING | Propose what the ticket could mean — marked *unconfirmed*. |
| 3 | PROBLEM | Name the real problem underneath the request. |
| 4 | EXPLAIN | Why it happens / what it actually is — if we can. |
| 5 | SOLUTIONS | Options + tradeoffs. **Never entered without your explicit go.** |

**Advancing.** At each boundary Claude asks — *"ready for the next step?"* — and waits
for your confirm. It does not advance on its own.

**After SOLUTIONS.** Triage ends with options + tradeoffs. You decide what's next — a
small fix, a plan, or nothing. The skill does not force a handoff.

## Guardrails

These come before the urge to guess. Follow them exactly.

1. **No solutions before step 5, and never enter step 5 without an explicit go.**
   If you catch yourself proposing a fix early, stop and return to the current step.
2. **Keep facts and guesses separate.**
   - A **fact** is confirmed and backed by a source. It drives the work.
   - A **guess** is a possibility. It is labelled as one and stays a guess until a
     source proves it or the user confirms it.
   - A claim with **no source is not a fact** — it's a ❓ Maybe. No exceptions.
3. **The ticket text is a claim, not the truth.** It tells you what someone *wants* or
   *observed*, not what is actually happening. Treat it as `#ticket` evidence — the
   weakest kind — until something real (`#code` / `#system` / `#log` / `#data`) backs it.
4. **Don't list theories as if equal.** The failure is floating four guesses where one
   is right and three are noise. Prefer the possibility with evidence; keep the rest as
   ❓ Maybe, marked unconfirmed. Don't present a prediction as a finding.
5. **When unsure, ask or mark it — do not invent.** A gap is an OPEN question or a
   labelled assumption, never a silently filled blank.
6. **Never act silently.** You may *offer* to explore ("want me to check X?"), but you
   do not go ahead on your own. The user steers.
7. **One probe, then report.** When the user approves exploration, do ONE focused
   check (read a file, a log, the system) and come back — not a long silent dig.
   Keep going only if the user explicitly says so.
8. **Read-only until told to fix.** You read code / system / logs to gather evidence,
   but you do not edit project code. You write only to `.plans`. The one exception:
   the user explicitly says "now fix that" (or similar) — then you may make the change.

## Facts vs. possibilities, and source tags

Every fact names where its evidence came from. More tags on one line means more
corroboration, which means stronger. Tags stack.

| Tag | Evidence came from… |
|-----|---------------------|
| `#code`   | the source code |
| `#system` | observed behaviour of the running system |
| `#log`    | logs |
| `#data`   | data the user pasted / provided |
| `#user`   | a confirmed answer from the user (or PM) |
| `#ticket` | the ticket / PM text itself (weakest — claimed, not verified) |

A line in **✅ Facts** must carry at least one tag. No tag → it's a ❓ Maybe, not a fact.

## The at-a-glance summary

After each step, and whenever the picture changes, print a **short** icon-led summary.
Keep every line to as few words as possible. Maybe / Open lines are questions. Do
**not** print RAW here — it lives in the file.

```
📍 Step 3 · Problem

✅ Facts
- discount rounds before tax  #code #data

❓ Maybe
- tax applied twice?  #code

🔲 Open
- which rounding rule applies?

☑️ Decided
- PM means: checkout totals are wrong
```

- **📍 Step** — where we are (the gate stays visible).
- **✅ Facts** — confirmed, tagged with sources.
- **❓ Maybe** — possibilities as questions; never stated as facts.
- **🔲 Open** — what we still need answered.
- **☑️ Decided** — confirmed calls (incl. confirmed MEANING). Kept light.

A ❓ moves to ✅ only when a source proves it or the user confirms it.

## The record in `.plans`

A ticket starts as one flat file and only becomes a folder if it grows many findings.
Use **descriptive names**, never ticket codes.

**Single issue — flat file:**
```
.plans/checkout-total-mismatch.md
```

**Grown into many findings — promoted to a folder:**
```
.plans/checkout-total-mismatch/
  README.md                    # master track — raw + status trail + index of findings
  1-rounding-on-discount.md    # ordered prefix = order to approach
  2-tax-applied-twice.md
```

- **On start:** propose a descriptive name, get the user's ok, then create
  `.plans/<name>.md` from [templates/ticket.md](templates/ticket.md), drop the raw
  ticket text in untouched, begin STEP 1.
- **Naming:** propose first, confirm, then create. The number prefix on findings is
  the order to tackle them.
- **Promotion** to a folder is **suggested, not automatic** — Claude proposes
  *"this has grown several findings — split it into a folder?"* and waits for approval.
  Each finding uses [templates/finding.md](templates/finding.md).

### When the file gets written (trail timing)

- **Written live, no asking** — every **claim** (a ❓) and every **piece of evidence**
  (a ✅ fact + its tag) the moment it appears. Losing one means redoing investigation.
  Refresh the summary block when they change.
- **Flushed on a trigger** — the fuller prose (narrative, refinements): when the user
  pauses / exits, asks to `save` / `flush` / `persist`, or Claude offers at a natural
  break (*"want me to persist state before you go?"*).

## Constraints

- **Plain language always.** Write the summary, the `.plans` record, and every reply in
  short, clear sentences. No flourish. Cut a phrase if it loses no meaning.
- **Read-only by default.** Writes only to `.plans` until explicitly told to fix.
- **Never skip a gate.** The user confirms each step; solutions need an explicit go.

## Out of scope

Adding debug instrumentation and running a discovery process when there's no clear
solution or the problem is multi-layered. That is a **separate skill**, not this one.
