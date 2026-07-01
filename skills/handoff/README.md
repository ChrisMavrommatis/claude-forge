# handoff

Distil the current session into a compact carry-forward note so you can safely `/clear`
and resume later with context intact.

Context is the scarce resource. When a session fills up you clear it — and lose anything
that wasn't written down. This skill writes it down first: it reads **this conversation**
and distils it into a short, structured note in `.plans/`, then tells you it's safe to
clear. The note is the durable memory that survives the reset.

It is a **distillation, not a transcript** — the smallest note that lets a cold reader,
or a fresh session, pick up cleanly.

It runs **inline** (it has to see the live conversation), writes **only** to `.plans/`,
and never touches project code.

## Use it

```
/handoff                  # propose a name from the session topic, confirm, then write
/handoff auth-refactor    # use this name/focus for the note
```

Fires only when you ask — it won't write a handoff note on its own.

## What it captures

Six short sections, each trimmed to the fewest lines that let someone resume:

- **Goal / task** — what we're doing, in one or two lines.
- **Decisions made** — each with a one-line *why*, so they aren't re-litigated.
- **Current state** — done, in progress, verified vs. not.
- **Open questions / blockers** — what still needs an answer.
- **Next concrete step** — the single most useful thing to do first on resume.
- **Files touched** — paths changed this session, committed vs. uncommitted if known.

The note is written to `.plans/<descriptive-name>.md` (repo-root `.plans/`, which is
gitignored), so it stays local until you promote it.

## File layout

```text
handoff/
├── SKILL.md            core spec — what it captures and how it runs
├── AGENT.md            orientation for an agent reading this skill cold
└── README.md           you are here
```

## Install

From the repo root, using the installer in [`bin/`](../../bin/README.md):

```bash
# Linux / Mac
bin/install.sh handoff

# Windows (PowerShell)
bin\install.ps1 handoff
```

See the parent [README](../../README.md) for repo-level context.
