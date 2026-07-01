# <descriptive feature name — what it does, not a ticket code>

> feature-scope record. The status block is the at-a-glance view; everything below it is
> the full record. Unknowns, choices, decisions, knowns, and the size are written live;
> prose is flushed on request. This maps WHAT we'd build, HOW (approach-level), and HOW BIG
> — the detailed build plan is a separate, later step.

## Status

📍 feature-scope · <name>

🎯 Ask
- <the want, restated in one line>  #request

🧩 Build — what & how
- <a part of work + its approach / where it connects>  <#request | #code | #pattern>
- <a part with a choice>  ← CHOICE:
    · <option A> — <its tradeoff>
    · <option B> — <its tradeoff>
    → pick: <which & why, in context>  <tag>

🕳️ Unknowns
- <an open question / undecided choice whose answer moves the build or the size>

☑️ Decided
- <a settled choice or decision → the call>  #user

⚠️ Risks
- <what could go wrong — technical / scope / approach / data>  <#code | #assumption | …>

📏 Size
- <XS|S|M|L> · <Low|Medium|High> confidence — <one-line why; an unresolved hard blocker forces Low>
  → <what closing which unknowns / settling which choice / confirming which blocker would move it to>

---

## Request (untouched)

<the client / PM words, exactly as received — never edited>

## Discovery — detail

<what the setup discovery pass over the code found (if one ran): where the feature would
connect, mechanisms it could reuse, entry points it touches, anything that would block the
obvious approach. The parts and choices below draw on this. If the pass was skipped (trivial
XS or the user declined), say so.>

## Build — detail

<fuller breakdown of each part: what it involves, where it connects, and for each choice the
options, their tradeoffs, and the reasoning behind the pick. Note how each part was settled —
a decision, the user's stated approach (with the alternatives check against it), or a finding
from exploration. High-level names live in the status block above.>

## Unknowns — detail

<each open question, which kind (spec → ask user / code → check / decision → decide /
feasibility → confirm the blocker), and what its answer would change. As unknowns close, note
how the size moved. Flag any confirmed hard blocker holding confidence at Low.>

## Risks — detail

<each risk: trigger, rough likelihood, rough impact, and whether it's backed by a source or
assumed.>

## Notes

<reasoning, code findings from checks, anything that doesn't fit above. Flushed on pause /
exit / on request — the status block stays current regardless.>
