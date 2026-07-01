# handoff — agent brief

Read this first if you're picking up this skill cold. It orients you to what this is,
how it works, and the calls behind it.

## What this skill is for

Distilling the current session into a compact carry-forward note so the user can safely
`/clear` and resume later with context intact. The note lives in `.plans/` and is the
durable memory that survives a context reset. It captures the minimum a cold reader needs
to pick up: goal, decisions (with reasons), current state, open questions, next step,
files touched.

## Mental model

- **The skill is prompt-based.** No compiled code. The Markdown IS the implementation.
  `SKILL.md` is the always-loaded core; there are no on-demand support files.
- **One artefact per run:** the `.plans/<name>.md` note. It is a distillation, not a
  transcript — the smallest note that lets a fresh session resume cleanly.
- **It reads the live conversation, not the codebase.** The source material is THIS
  session's history. Git state is checked only to fill *Files touched* accurately.
- **Read-only until it writes.** It writes exactly one file, in `.plans/`. Never edits
  project code.

## Where to look for what

| I want to change                        | Edit                              |
| --------------------------------------- | --------------------------------- |
| Invocation / argument / naming          | `SKILL.md` → How it runs, step 2  |
| The six captured sections               | `SKILL.md` → What it captures     |
| The run flow (read → name → write → tell) | `SKILL.md` → How it runs         |
| The example note shape                  | `SKILL.md` → Example note         |
| Plain-language / write-scope rules      | `SKILL.md` → Constraints          |

## Design history — the big calls

- **Runs INLINE. Does NOT fork and does NOT dispatch a subagent.** This is the opposite
  of the reviewer skills (`plan-review`, `skill-review`, `panel-review`), which fork or
  dispatch a fresh subagent precisely so the review is *independent* of the current
  conversation. Handoff needs the exact reverse: its whole job is to summarise THIS
  conversation, and a forked or dispatched agent starts with a clean context and cannot
  see the session it's meant to distil. So: no `context: fork`, no `Agent` dispatch — the
  work happens in the live inline context that holds the conversation.
- **`disable-model-invocation: true`.** It writes a file, and writing a handoff note
  unprompted would be surprising. It fires only when the user asks (`/handoff`).
- **Distillation, not transcript.** The failure mode to avoid is dumping the whole
  conversation. Capture only what's needed to resume; leave empty sections out rather
  than padding them.
- **Decisions carry a one-line *why*.** Without the reason, a fresh session re-litigates
  settled calls. The rationale is what stops that.
- **Descriptive names, confirmed before writing.** Same habit as `ticket-triage`: propose
  a name from the session topic, confirm, then create. Never codes.
- **Writes to repo-root `.plans/`** (gitignored per `CLAUDE.md`), so the note stays local
  until explicitly promoted.

## Deliberately out of scope

- **Committing code or saving diffs.** Handoff records *what changed and where*, not the
  changes themselves. Committing is a separate action the user drives.
- **Auto-firing at context limits.** Only fires on explicit invocation.
- **Reconstructing a session from git history.** The source is the live conversation; if
  there's no conversation to read, there's nothing to hand off.

## Pitfalls / don'ts

- **Don't fork or dispatch.** A subagent can't see this conversation — the note would be
  empty or invented. Run inline.
- **Don't write a transcript.** Distil. Short, scannable, resume-focused.
- **Don't invent state.** If something wasn't verified, say "not verified". If a decision
  wasn't made, it's an open question, not a decision.
- **Don't edit project code.** Write exactly one file, in `.plans/`.
- **Don't skip the name confirm** when the user didn't pass one.
