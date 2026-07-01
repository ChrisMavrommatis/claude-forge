# Getting the most out of Claude Code

A short, opinionated guide. The organising idea:

> **Every practice is information routing** — deciding what enters the
> agent's context, when, and who controls the gate.
>
> The human and the agent fail in opposite ways. The **human** fails by
> losing the ability to steer and verify. The **agent** fails by being
> starved of relevant context, or drowned in irrelevant context.
>
> The best practices **narrow what the agent must reason over** while
> **widening what the human can inspect and correct**. Most "productivity
> tricks" optimise one at the other's expense.

---

## The short version

If you do only five things:

1. **Plan first, on a reviewable artifact** — then steer at that gate, not mid-generation.
2. **Keep `CLAUDE.md` ruthlessly lean** — only rules that change real behaviour.
3. **Give the agent a verification loop it can run itself** — and make it real, not gameable.
4. **Delegate to subagents only to isolate heavy, independent context** — expect ~15× tokens, demand distilled returns.
5. **Auto-allow read-only, gate writes** — control without starving the agent.

---

## Tier 1 — Serve both human and agent

*Highest value. Ranked.*

### 1. Plan before code

The single highest-leverage move. A plan the human approves *before*
execution gives the agent a committed target (less drift, less
re-derivation) and the human a cheap checkpoint to steer when steering is
cheapest.

> Correcting a bad plan costs a paragraph. Correcting bad code costs a
> review cycle.

⚠️ **Backfires** on trivial or purely exploratory work — the overhead
exceeds the task.

### 2. A lean, high-signal `CLAUDE.md`

Auto-loaded every turn — your highest-frequency context. Done right, the
agent stops re-deriving conventions and you stop repeating yourself.

⚠️ **Backfires** as a junk drawer: every token is paid on *every* turn and
dilutes attention. Test each line —

> *"Would this change behaviour on a real task?"* If not, delete it.

### 3. A verification loop the agent can run itself

Tests, lint, build, typecheck. The rare thing that helps both sides: the
agent gets ground truth to self-correct against; you get an objective gate
instead of reading every diff.

⚠️ **Backfires** when the check is weak or gameable — false confidence for
everyone.

### 4. Read before write — ground every claim in a source

Attacks the agent's worst failure mode (confident fabrication) and gives
you traceable provenance.

⚠️ **Backfires** when forced onto cheap one-line changes.

---

## Tier 2 — Primarily aid the agent

| Practice | What it's for | Backfires when… |
| --- | --- | --- |
| **Subagent delegation** | Keep a noisy sub-task (scan, API dump) *out of* the main thread. Costs **~15× tokens** — only pays off on genuinely independent work. | Subtasks are coupled → fragmentation, duplicated effort, worse output. |
| **Skills** (agent decides) | Progressive disclosure — the agent sees a description, loads the body on demand. | Descriptions overlap or overclaim → wrong skill auto-fires. |
| **Structured tool / MCP output** | Return relevant fields, not raw dumps. | Verbose JSON on every call, or "just in case" server sprawl — each schema is permanent context cost. |

---

## Tier 3 — Primarily aid the human

*(with hidden cost to the agent)*

| Practice | Aids the human by… | Hidden cost |
| --- | --- | --- |
| **Slash commands** (human decides) | Deterministic, no auto-selection ambiguity. | Cognitive load you carry — things you forget to invoke never fire. |
| **Permission modes** | Trust and blast-radius control. | Too tight **starves the agent mid-task**; too loose loses oversight. Target: auto-allow read-only, gate writes. |
| **Mid-task steering** | Correct a wrong assumption early. | Every interruption injects context and can knock the agent off a good plan. Steer at *checkpoints*, not every turn. |

**Skill or slash command?** The decision rule is one question:

> **Who decides when it runs?**
> Human → slash command.  Agent should notice it's needed → skill.

---

## Anti-patterns

*Ranked by how much value they destroy.*

1. **Bloated `CLAUDE.md` / context hoarding** — treating context as free when it's the scarcest per-turn resource. Longer context *lowers* quality on every later turn.
2. **Reflexive multi-agent fan-out** — ~15× tokens for fragmented, harder-to-verify output on coupled tasks.
3. **Skipping the plan on non-trivial work** — you pay generation tokens twice, review time thrice.
4. **Weak verification dressed as rigor** — worse than none; it disarms scrutiny.
5. **MCP / tool sprawl** — permanent schema cost + noisier auto-selection.
6. **Micromanagement steering** — feeling in control while degrading the run.
7. **Skill/command confusion** — built by the wrong control locus, so it fires unprompted or never fires.
8. **Letting sessions accrete junk** — instead of compacting or clearing deliberately.

---

## The through-line

> **Context is the scarce, shared resource. Control is what the human must
> not trade away.**

Practices that shrink what the agent reasons over while growing what the
human can inspect — planning, verification, lean memory, isolated
delegation with distilled returns — are the compounding wins. Anything that
treats context as free, or buys comfort by cutting one party out of the
loop, is where value quietly leaks.

---

## Sources

- [Building Effective AI Agents](https://www.anthropic.com/research/building-effective-agents) — Anthropic
- [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — Anthropic
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) — Anthropic
- [Claude Code documentation](https://code.claude.com/docs)
