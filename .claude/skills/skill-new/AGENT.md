# skill-new — agent brief

Read this first if you're picking up this skill cold. It orients you to what this is,
how it works, and the calls behind it.

## What this skill is for

Scaffolding a new skill in this repo, laid out to the repo's conventions. It collects a
name, a scope (installable or project-scoped), and a one-line purpose, then creates the
folder in the right place with a valid `SKILL.md`, the dev-facing files the scope needs,
and an index row. The goal: a new skill that passes `skill-lint` and `skill-review` from
the first commit, so the author starts from a correct shell instead of hand-building
boilerplate.

## Mental model

- **Prompt-based, no compiled code.** The Markdown IS the implementation. `SKILL.md` is
  the whole skill.
- **Side-effecting — it writes files.** That is why the frontmatter sets
  `disable-model-invocation: true`: the skill only fires when the user types it, never on
  Claude's own initiative. A scaffolder that ran unprompted would create folders nobody
  asked for.
- **Runs inline — does not fork.** There is no `context: fork`. Scaffolding is a direct
  action in the current conversation; a cold subagent would only lose the arguments and
  add latency.
- **Skeleton only.** It writes valid structure with `TODO:` markers, not real behaviour.
  The author fills in the body afterwards and re-checks with `skill-lint` /
  `skill-review`.
- **Two scopes, one branch.** Installable goes under `skills/` with `AGENT.md`,
  `README.md`, and `.skillignore`; project-scoped goes under `.claude/skills/` with no
  `.skillignore`. The scope also picks which index gets the new row.

## Where to look for what

| I want to change                          | Edit                                |
| ----------------------------------------- | ----------------------------------- |
| Argument handling / what's asked for      | `SKILL.md` → Inputs                 |
| The scaffolding steps                     | `SKILL.md` → What to do             |
| Which files each scope produces           | `SKILL.md` → What gets created      |
| The frontmatter `description` rules        | `SKILL.md` → The description standard |
| The next-steps reminder                    | `SKILL.md` → Report                 |
| Whether it forks / auto-invokes            | `SKILL.md` frontmatter (`context`, `disable-model-invocation`) |
| Pre-approved tools                         | `SKILL.md` frontmatter (`allowed-tools`) |

## Design history — the big calls

- **Not auto-invocable.** `disable-model-invocation: true` keeps a file-writing action
  behind an explicit user command. This is the same "who decides when it runs?" call the
  repo guide makes — a side effect belongs to the human, not the agent.
- **Not forked.** `skill-review` forks for independence; a scaffolder has nothing to gain
  from a cold read and would lose the invocation arguments. It runs inline.
- **Scaffolds to pass the checkers.** The output is shaped so `skill-lint` and
  `skill-review` pass on it immediately — matching folder-vs-`name`, an `Examples —`
  line, the right dev files per scope, and an index row. The two checkers define
  "correct"; this skill produces exactly that shape.
- **Scope drives everything.** Location, dev files, `.skillignore` presence, and which
  index gets the row all follow from installable vs project-scoped.

## Pitfalls / don'ts

- **Don't overwrite an existing skill.** Check the target folder first; if it exists,
  stop.
- **Don't guess the inputs.** Ask for a missing name, scope, or purpose — a wrong scope
  puts the skill in the wrong place with the wrong files.
- **Don't write a `.skillignore` for a project-scoped skill.** Those have no install step.
- **Don't fill in real behaviour.** Leave `TODO:` markers; the skeleton is the deliverable.
- **Don't forget the index row.** A skill with no row fails both checkers.
