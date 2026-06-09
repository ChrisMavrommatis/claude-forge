# Template: panel-failed

The terminal abort block rendered when every dispatched persona
errored. No `panel-overview` box, no verdict, no table — nothing to
consolidate.

## Shape

```text
  [!] PANEL FAILED — no verdict possible
  ─────────────────────────────────────────────────────────────

  All 6 personas errored. Nothing to compare; no convergence to
  compute; the panel can't produce a verdict.

  Failures:
    - DEV        agent error: rate limited
    - TECH LEAD  agent error: timeout after 60s
    - QA         agent error: refused (no permission)
    - PM         agent error: network failure
    - CLIENT     agent error: rate limited
    - JUNIOR     agent error: timeout after 60s

  Try again, or check connectivity / quotas / model availability.
```

## Structure

1. **`[!] PANEL FAILED — no verdict possible`** heading at col 2.
2. **Horizontal rule** at col 2, 62 dashes.
3. **Explanation line** at col 2: `All <N> personas errored.
   Nothing to compare; no convergence to compute; the panel can't
   produce a verdict.`
4. **`Failures:`** heading at col 2.
5. **Failure list** at col 4 with `-` bullets. Persona name padded
   to longest-name-width + 4 spaces so `agent error:` aligns.
6. **Recovery line** at col 2: `Try again, or check connectivity /
   quotas / model availability.`

## No retry prompt

No personas to drill into, no menu. The user re-runs
`/panel-review` manually.

## Don't render

- TOP issues
- Details prompt
- Drill-in footer
- `panel-overview` box

## Used by

Screen 8 (all personas failed). Compare Screen 7 (one persona
failed), where the panel still produces a verdict and renders
normally with `! FAILED` rows inline in the table.
