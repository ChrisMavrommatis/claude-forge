# Template: veto-block

The actionable gate block that appears **above** `panel-overview` on
Screen 3 (REJECT with active veto). The only content that ever
appears before the run-meta box, because the user must respond to it
before the verdict resolves.

## Shape (single veto)

```text
  [!] VETO  ·  SECURITY says this should not ship
  ─────────────────────────────────────────────────────────────

  Finding:  Hardcoded API key in client config
       ·  src/config/client.ts:18

  Why veto-level (security lens):
    Key is shipped to every browser that loads the page. Anyone can
    extract it from devtools and call our paid API on our dime.

  To proceed:
    - Fix the issue and rerun.
    - Reply:  accept veto: <your reason in one line>
    - Or pass --accept-veto="<reason>" on the next invocation.

  Until acknowledged, OVERALL stays REJECT.
```

## Subsection order (fixed)

1. **`[!] VETO  ·  <PERSONA> says this should not ship`** —
   heading + horizontal rule at col 2.
2. **`Finding:`** — title + `·` file:line (uses the issue
   three-layer indent without the `[SEVERITY]` opener).
3. **`Why veto-level (<persona> lens):`** — verbatim rationale
   from the persona's `Veto-level findings` entry. Indented 2
   spaces under the heading.
4. **`To proceed:`** — `-` bullets at col 4 with the three
   action options.
5. **Status line** at col 2: `Until acknowledged, OVERALL stays
   REJECT.`

## Multi-veto layout

Stack one veto subsection per persona in panel order (required →
optional → custom alphabetical). Share the `To proceed:` block at
the end with a `(applies to all vetos above)` qualifier:

```text
  [!] VETO  ·  SECURITY says this should not ship
  ─────────────────────────────────────────────────────────────

  Finding:  Hardcoded API key in client config
       ·  src/config/client.ts:18

  Why veto-level (security lens):
    Key is shipped to every browser...


  [!] VETO  ·  ACCESSIBILITY says this should not ship
  ─────────────────────────────────────────────────────────────

  Finding:  Checkout form unusable with screen readers
       ·  src/components/CheckoutForm.tsx:142
       >  no aria-labels, no semantic structure, no live regions

  Why veto-level (accessibility lens):
    The submit button has no accessible name...


  To proceed (applies to all vetos above):
    - Fix the issues and rerun.
    - Reply:  accept veto: <your reason>  (will be asked once per veto)
    - Or pass --accept-veto="<reason>" to acknowledge all at once.

  Until all vetos are acknowledged, OVERALL stays REJECT.
```

## Companion: panel-overview verdict line

When a veto is active, `panel-overview` carries the status:

- Single veto: `VERDICT:  REJECT — veto pending`
- Multi-veto: `VERDICT:  REJECT — 2 vetos pending`
- Tally suffix: `· 1 veto` / `· 2 vetos`

## TOP block marker

The veto source appears in TOP block (sorted to top) with
`← veto source` (pending) or `← veto source (accepted)` after the
title.

## After acknowledgment (Screen 4)

Veto block disappears entirely. Footnote(s) move inside the
`panel-overview` box. Verdict becomes `HOLD†`. See Screen 4
in the design doc for the post-override layout.

## Used by

Screen 3 (REJECT with active veto). Acknowledgment moves the state
to Screen 4, which renders without this block.
