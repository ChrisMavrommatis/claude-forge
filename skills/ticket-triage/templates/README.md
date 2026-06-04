# templates

File shapes the skill writes into `.plans`. Read the relevant one only when creating
that file — not on every run.

| Template | Used for |
| -------- | -------- |
| [ticket.md](ticket.md)   | The flat ticket file (`.plans/<name>.md`), also the basis for `README.md` when a ticket is promoted to a folder. |
| [finding.md](finding.md) | One finding file (`N-<name>.md`) inside a promoted ticket folder. |

Both lead with a **Status** block (the at-a-glance view — `📍 Step`, `✅ Facts`,
`❓ Maybe`, `🔲 Open`, `☑️ Decided`) and keep the fuller record below it.
