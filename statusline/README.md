# Custom status line

A cross-platform status line for Claude Code. One Node script, no
dependencies, works on Windows / macOS / Linux. Every segment renders
only when it has data, so the line stays clean across different project
types.

## What it shows

Segments are **grouped by purpose**, separated by a grey `│` divider. Three
visibility tiers: the primary fact in each group is in colour, the session
label is soft white, and the secondary details are dim grey. It's one line
and wraps naturally if the terminal is narrow.

```
📁 forge .NET 10.0  │  🌱 feature/x ↑2 ↓1 ● @ 2h  │  🤖 Opus 4.8 🎚 high 🧠 42% 85k/200k  │  💰 $0.42 +120 -8 ⏱ 14m  │  ⚡ 5h:34% 7d:12%  │  🏷 checkout
└──── where ────┘   └──── source control ────┘   └──────── engine ────────┘   └──── spend ────┘   └─ account ─┘   └─ session ─┘
```

| Group          | Primary (colour)        | Secondary (faint)                         |
| -------------- | ----------------------- | ----------------------------------------- |
| Where          | 📁 dir                  | detected toolchain(s)                     |
| Source control | 🌿 branch (git-flow)    | `↑n ↓n` ahead/behind · `●` dirty · `@ age`|
| Engine         | 🤖 model                | 🎚 `effort.level` · 🧠 context*           |
| Spend          | 💰 `cost.total_cost_usd`| `+adds -dels` · ⏱ duration                |
| Account        | ⚡ `rate_limits`        | —                                         |
| Session        | —                       | 🏷 `session_name`                         |

\* Context (`context_window`) keeps its own green/yellow/red colour — the
colour is the warning, so it isn't dimmed. Each group is omitted when it
has no data.

### git-flow badges

`🌱 feature/` · `🚀 release/` · `🔥 hotfix/` · `🐞 bugfix/` ·
`🌲 develop` · `🌿 anything else (main, etc.)`

### Detected toolchains

Walks up from the working directory to the repo root looking for:

| Stack  | Detected from                                  | Version from              |
| ------ | ---------------------------------------------- | ------------------------- |
| .NET   | `global.json`, or any `.sln`/`.slnx`/`.csproj` | `global.json` sdk.version |
| Node   | `package.json`                                 | `.nvmrc` or engines.node  |
| Python | `.python-version`, `pyproject.toml`, `requirements.txt` | `.python-version` |
| Rust   | `Cargo.toml`                                   | —                         |
| Go     | `go.mod`                                       | `go.mod` go directive     |

## Install

1. Copy `statusline.js` somewhere stable (e.g. `~/.claude/statusline.js`),
   or point at it where it lives.
2. Add to your Claude Code `settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "node /absolute/path/to/statusline.js"
     }
   }
   ```

   On Windows, escape backslashes:
   `"node \"C:\\Users\\you\\.claude\\statusline.js\""`

3. Start a new Claude Code session (or reload via `/config`).

Requires `node` on your `PATH`.

## Why no network calls

The status line re-renders constantly, so every segment is local and
fast (git plus a few small file reads). Things that need an API — PR
status, build state, ticket info — belong in a slash command or brief,
not here.

## Customizing

Segments are assembled in one `segments.push(...)` block near the bottom
of `statusline.js`. Reorder, drop, or recolor them there. Colors are
plain ANSI via the `C(code, text)` helper.
