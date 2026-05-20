# Failure handling

Spec for when one or more personas fail. Loaded only when at least
one persona's dispatch errors out. A "failure" is any Agent dispatch
that errors — timeout, rate-limit, refusal, network failure, malformed
response, or any other reason the persona didn't produce parseable
output.

## One or more personas failed (not all)

If at least one persona returned successfully, the panel still
produces a verdict. Failed personas are skipped in convergence and
tally; surviving personas drive the result.

### Banner meta line

The `panel-overview` meta line gains `+ <K> failed` after the
personas count (per [templates/overview/panel-overview.md](templates/overview/panel-overview.md)):

```text
│  range:main..HEAD  ·  18 files  ·  4 personas + 1 failed    │
```

The `+ <K> failed` segment is omitted when zero personas failed.

### Verdict-table row

The failed persona shows inline as a regular row, with `! FAILED`
in the VERDICT column and the error message in REASON:

```text
  PERSONA      VERDICT       REASON
  ─────────────────────────────────────────────────────────────
  DEV          ▸ HOLD        rounding bug blocks ship
  TECH LEAD    ! FAILED      agent error: timeout after 60s
  QA           ▸ HOLD        need test for rounding edge first
  PM           ✓ SHIP        scope matches the ticket
  CLIENT       ✓ SHIP        end-to-end story still works
```

`! FAILED` is 8 chars (same as `✗ REJECT`); the VERDICT column
auto-sizes to fit. See [templates/overview/verdict-table.md](templates/overview/verdict-table.md).

### Failure section in the details view

When the user requests `--details` or names the failed persona,
the failed persona appears in the details stack as a compact
section instead of a full card:

```text
  TECH LEAD  ·  ! FAILED
  ─────────────────────────────────────────────────────────────

  Agent error:  timeout after 60s

    Failed personas don't count toward convergence or tally.
    Rerun /panel-review to retry.
```

No `Lens:` / `Good:` / `Issues:` / `Unique findings:` etc — the
agent didn't produce them. Just the error + a status note.

If the user names the failed persona directly (`"TECH LEAD"`), the
same compact section renders alone — no point dispatching a
drill-in agent against a persona that didn't return output.

### Rules

- Failed personas are **excluded from convergence counts** (no false
  negatives).
- Failed personas **don't contribute to the verdict tally** — the
  `3 HOLD · 2 SHIP · 0 REJECT` counts include only personas that
  returned. A 5-persona panel with 1 failed produces a tally that
  sums to 4, not 5.
- The header banner counts successful personas separately from
  failed ones: `<target> · <N> files · <M> personas + <K> failed`.
- A veto-eligible persona that fails **cannot cast a veto** — no
  output to scan for veto-level findings. Other veto personas (if
  any) still fire normally.
- **No automatic retry.** If the user wants to retry, they rerun
  `/panel-review`.

## All personas failed

If every persona dispatched returns a failure, the panel can't
produce a verdict. Render the abort section per
[templates/alerts/panel-failed.md](templates/alerts/panel-failed.md):

```text
  [!] PANEL FAILED — no verdict possible
  ─────────────────────────────────────────────────────────────

  All 5 personas errored. Nothing to compare; no convergence to
  compute; the panel can't produce a verdict.

  Failures:
    - DEV        agent error: rate limited
    - TECH LEAD  agent error: timeout after 60s
    - QA         agent error: refused (no permission)
    - PM         agent error: network failure
    - CLIENT     agent error: rate limited

  Try again, or check connectivity / quotas / model availability.
```

Do not render a `panel-overview` box, do not produce a partial
verdict, do not "best-guess" a SHIP. Exit immediately so the user
sees the actual cause.

## See also

- [templates/alerts/panel-failed.md](templates/alerts/panel-failed.md) — the all-failed abort section.
- [templates/overview/verdict-table.md](templates/overview/verdict-table.md) — table behaviour for the `! FAILED` row.
- [templates/details/persona-card.md](templates/details/persona-card.md) — the compact failed-persona section is documented there as a variant.
