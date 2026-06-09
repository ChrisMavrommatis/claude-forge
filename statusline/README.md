# Custom status line

A cross-platform status line for Claude Code. One Node script, no
dependencies, works on Windows / macOS / Linux. Every segment renders
only when it has data, so the line stays clean across different project
types.

## What it shows

```
📁 forge  •  🌱 feature/x ↑2 ↓1 ●  •  @ 2h  •  .NET 10.0  •  ⬢ 20  •  🤖 Opus 4.8  •  💰 $0.42  •  📝 +120 -8  •  ⏱ 14m  •  🕐 14:32
```

| Segment        | Source            | Shows when                          |
| -------------- | ----------------- | ----------------------------------- |
| 📁 dir         | session JSON      | always (project-relative if inside) |
| git-flow badge | branch name       | in a git repo                       |
| `↑n ↓n`        | `git rev-list`    | ahead/behind upstream is non-zero   |
| `●`            | `git status`      | working tree is dirty               |
| `@ age`        | last commit time  | in a git repo                       |
| toolchain(s)   | manifest files    | a known stack is detected           |
| 🤖 model       | session JSON      | always                              |
| 💰 cost        | session JSON      | session cost > 0                    |
| 📝 +adds -dels | session JSON      | lines changed this session          |
| ⏱ duration    | session JSON      | session has run time                |
| 🕐 clock       | local time        | always                              |

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
