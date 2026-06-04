# The five steps

Walked in order. Claude asks at each boundary and waits for the user's confirm before
moving on. The hard stop is before STEP 5 — never enter it without an explicit go.

For each step: what to do, what NOT to do, and how to leave it.

---

## STEP 1 — RAW

**Do:** Restate the ticket's words as they are. Drop them into the `.plans` file
untouched. Strip nothing, add nothing.

**Don't:** interpret, summarise into your own framing, or hint at a cause. No "this
sounds like a caching issue." Just the raw words, mirrored back so we share a starting
point.

**Leave it:** once the raw text is captured, say what you see at face value (who wants
what, in their words) and ask: *"ready to work out what this could mean?"*

---

## STEP 2 — MEANING

**Do:** Propose what the ticket could mean — in this context. Mark it **unconfirmed**.
This is a lens for investigation, not a conclusion. If more than one reading is
plausible, list them as separate possibilities.

**Don't:** treat your reading as established. Don't build on it. Don't slide from
"could mean" into "so the fix is…".

**Leave it:** the user confirms, corrects, or picks among readings. A confirmed meaning
goes to ☑️ Decided. Then ask: *"ready to find the real problem underneath?"*

---

## STEP 3 — PROBLEM

**Do:** Name the real problem under the request. Use the confirmed meaning as a lens to
hunt for clues — in code, the running system, logs, or data the user gives you. Every
clue either confirms a possibility, denies it, or raises a new OPEN question.

**Don't:** float four equal-looking theories. Prefer the possibility evidence supports;
keep the rest as ❓ Maybe. A clue with no source is not a fact — it's a guess.

**Investigation rule:** one focused probe, then report back. Say what you're about to
check before you check it. Don't disappear into a long dig unless the user says go on.

**Leave it:** when the problem is named and backed by at least one source, or when
you've hit a wall and need the user. Ask: *"ready to explain why this happens?"* — or,
if stuck, surface the OPEN questions and ask how to proceed.

---

## STEP 4 — EXPLAIN

**Do:** Explain why the problem happens / what it actually is — *if we can*. Tie the
explanation to facts with sources. If the cause is only partly understood, say exactly
how far the evidence goes and where it runs out.

**Don't:** manufacture a tidy story to fill gaps. An unexplained part stays an OPEN
question, not a confident guess. "We don't yet know why X" is a valid, honest output.

**Leave it:** when the explanation is as solid as the evidence allows. This is the last
gate. Ask explicitly: *"want me to move to solutions?"* — and wait. Do not start
listing fixes until the user says yes.

---

## STEP 5 — SOLUTIONS

**Entered only on an explicit go.** If the user hasn't said "yes, solutions" / "go" /
"options please", you are not here yet.

**Do:** Lay out the options. For each: what it is, what it costs, what it risks, what it
leaves unsolved. Weigh them honestly. Note which the evidence favours and why.

**Don't:** pick for the user, or present one option as the only one. Don't start
implementing — triage ends at options.

**Leave it:** the user decides. Could be a small fix, a plan, or nothing. If the user
explicitly says "now fix that" (or similar), you may leave read-only and make the
change — otherwise you stay hands-off the code.

---

## If a second problem appears mid-triage

Tickets sometimes hide more than one problem. When a distinct second problem surfaces:

- Note it as a finding, don't drop the current thread to chase it.
- If findings start to multiply, **suggest** promoting the flat file to a folder (one
  ordered file per finding) and wait for approval — never restructure silently.
- Each finding can be walked through these same five steps in its own file.
