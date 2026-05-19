# Failure handling

Spec for when one or more personas fail. Loaded only when at least one persona's dispatch errors out. A "failure" is any Agent dispatch that errors — timeout, rate-limit, refusal, network failure, malformed response, or any other reason the persona didn't produce parseable output.

## One or more personas failed (not all)

If at least one persona returned successfully, the panel still produces a verdict. Failed personas are skipped in convergence and tally; surviving personas drive the result.

### Verdict-table row

```
│ <NAME>     │ FAILED  │ agent error: <short>           │
```

### Compact failure card (in the details block, when shown)

```
╭─ Persona: <NAME>  ·  Verdict: FAILED ────────────────────────╮
│                                                              │
│  Agent error: <one-line summary of the error>                │
│                                                              │
╰──────────────────────────────────────────────────────────────╯
```

### Rules

- Failed personas are **excluded from convergence counts** (no false negatives).
- Failed personas **don't contribute to the verdict tally** (the `3 HOLD · 2 SHIP · 0 REJECT` counts include only personas that returned).
- The **header banner** counts successful personas separately from failed ones: `<target> · <N> files · <M> personas + <K> failed · <T>s` (the `+ <K> failed` segment only appears when any persona failed).
- A **veto-eligible persona that fails cannot cast a veto** — no output to scan for veto-level findings. Other veto personas (if any) still fire normally.
- **No automatic retry.** If the user wants to retry, they rerun `/panel-review`.

## All personas failed

If every persona dispatched returns a failure, the panel can't produce a verdict. Abort with this message and exit:

```
All personas failed — no verdict possible.

  Failures:
    - DEV       agent error: rate limited
    - TECH LEAD agent error: timeout after 60s
    - QA        agent error: refused (no permission)
    - PM        agent error: network failure
    - CLIENT    agent error: rate limited

Try again, or check connectivity / quotas / model availability.
```

Do not render a banner, do not produce a partial verdict, do not "best-guess" a SHIP. Exit immediately so the user sees the actual cause.
