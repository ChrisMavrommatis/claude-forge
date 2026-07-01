---
name: handoff
description: Distil the current session into a compact carry-forward note so you can safely `/clear` and resume later with context intact. Reads THIS conversation and writes a short, scannable note to `.plans/` — goal, decisions and why, current state, open questions, next step, files touched. It is a distillation, not a transcript. Runs inline (it must see the live conversation). Writes only to `.plans/`, never project code. Use when you're about to clear context, hand off to a fresh session, or stop for the day. Examples — `/handoff`, `/handoff auth-refactor`.
argument-hint: [name-or-focus]
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Bash
---

# handoff

Context is the scarce resource. When a session fills up, you `/clear` and lose everything
that wasn't written down. This skill writes it down first: it reads the **current
conversation** and distils it into a compact, structured note in `.plans/` — the durable
memory that survives the reset. Then it tells you it's safe to clear.

The note captures only what a cold reader needs to pick up cleanly. It is a
**distillation, not a transcript** — short, plain, scannable. Prefer the smallest note
that lets a fresh session resume without re-deriving what this one already worked out.

## When to use

- You're about to `/clear` and want to keep context.
- You're stopping for the day and will resume later, maybe in a new session.
- The conversation is long and you want a clean checkpoint before continuing.

## When NOT to use

- You just want to save code changes — that's a commit, not a handoff note.
- Nothing meaningful has happened yet — there's nothing to carry forward.

## What it captures

Six sections. Keep each to the fewest lines that still let someone resume.

| Section | What goes in it |
|---------|-----------------|
| **Goal / task** | What we're doing, in one or two lines. |
| **Decisions made** | Each with a one-line *why*, so they aren't re-litigated on resume. |
| **Current state** | What's done, what's in progress, what's verified vs. not. |
| **Open questions / blockers** | What still needs an answer before the work can finish. |
| **Next concrete step** | The single most useful thing to do first on resume. |
| **Files touched** | Paths changed this session — mark committed vs. uncommitted if known. |

Leave a section out if it's genuinely empty. Don't pad it to look complete.

## How it runs

Inline, in this conversation — it has to see the live context (see [AGENT.md](AGENT.md)
for why it must not fork or dispatch). Four steps:

1. **Read the session.** Work out the goal, the decisions and their reasons, what's done
   vs. in progress, what's open, and the next step — from what actually happened in this
   conversation, not from guesses.
2. **Name it, confirm.** If `$ARGUMENTS` gave a name/focus, use it. Otherwise propose a
   descriptive name from the session topic (e.g. `auth-refactor`, `checkout-total-fix`)
   and confirm before writing. Descriptive names, never codes.
3. **Write the note** to `.plans/<name>.md` (repo-root `.plans/`, which is gitignored).
   Check git state first (`git status`, `git diff --name-only`) to fill *Files touched*
   accurately. Write only this file — never touch project code.
4. **Tell the user it's safe to `/clear`,** and how to resume (re-open the note, or run
   this session's skill again pointing at it).

## Example note

```markdown
# Handoff — auth-refactor

## Goal
Move session handling from cookies to signed JWTs, keep existing login UX.

## Decisions
- JWT in httpOnly cookie, not localStorage — avoids XSS token theft.
- 15-min access token + refresh token — matches the API team's existing pattern.
- Keep the old cookie path behind a flag for one release — safe rollback.

## Current state
- Done: token issue/verify in `auth/jwt.ts`, unit tests pass.
- In progress: refresh endpoint — wired but not yet verified end-to-end.
- Not started: migrating the logout flow.

## Open questions
- Which refresh-token store — Redis or DB? Waiting on infra's answer.

## Next step
Verify the refresh endpoint end-to-end: log in, wait for access-token expiry, confirm
silent refresh. Test lives in `auth/refresh.test.ts`.

## Files touched
- auth/jwt.ts — new, uncommitted
- auth/refresh.ts — new, uncommitted
- auth/login.ts — edited, uncommitted
```

## Constraints

- **Plain language always.** Short, literal sentences. Cut a phrase if it loses no
  meaning. No flourish.
- **Distillation, not transcript.** Capture what's needed to resume, not the play-by-play.
- **Read-only until it writes the note.** It writes exactly one file, in `.plans/`, and
  never edits project code.
- **Descriptive names, never codes.** Propose and confirm before writing.
