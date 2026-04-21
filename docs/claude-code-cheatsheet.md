# Claude Code Cheat Sheet

Reference for Claude Code, Anthropic's agentic CLI. Current as of April 2026, covering through v2.1.116 (the version installed by your `setup.sh`).

Official docs: <https://code.claude.com/docs>

---

## Table of Contents

- [Installation & Authentication](#installation--authentication)
- [CLI Flags (Invocation)](#cli-flags-invocation)
- [Slash Commands (In-Session)](#slash-commands-in-session)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Quick Prefixes](#quick-prefixes)
- [Permission Modes](#permission-modes)
- [CLAUDE.md (Project Instructions)](#claudemd-project-instructions)
- [Settings Files](#settings-files)
- [Hooks](#hooks)
- [MCP Servers](#mcp-servers)
- [Subagents](#subagents)
- [Models & Cost](#models--cost)
- [Common Workflows](#common-workflows)
- [Tips & Gotchas](#tips--gotchas)

---

## Installation & Authentication

Claude Code was installed by `setup.sh` via the native installer. Basic management:

```bash
claude doctor              # verify installation health
claude --version           # check installed version
claude update              # manually update (auto-updates by default)

# Authentication
claude auth login          # log in / switch accounts
claude auth status         # see who you're signed in as
claude auth logout         # clear credentials
```

First run opens a browser OAuth flow. Credentials persist in `~/.claude.json`.

---

## CLI Flags (Invocation)

Starting Claude with flags affects the whole session.

| Flag | Description | Example |
|---|---|---|
| `claude` | Start an interactive session | |
| `-p "prompt"` | Print mode: run one query, exit | `claude -p "list all TODOs"` |
| `-c` | Continue most recent session | `claude -c` |
| `-r NAME` / `--resume NAME` | Resume a named session | `claude -r "auth-refactor"` |
| `-n NAME` / `--name NAME` | Name a new session | `claude -n "feature-x"` |
| `--model MODEL` | Override default model | `claude --model opus` |
| `--max-turns N` | Limit autonomous turns | `claude -p "fix lint" --max-turns 10` |
| `--output-format FMT` | `text`, `json`, or `stream-json` | `claude -p "count files" --output-format json` |
| `--allowedTools "..."` | Restrict tools for this session | `--allowedTools "Edit,Bash(npm:*)"` |
| `--permission-mode MODE` | Set permission mode (see below) | `claude --permission-mode auto` |
| `--enable-auto-mode` | Start with Auto Mode on | `claude --enable-auto-mode` |
| `--dangerously-skip-permissions` | Skip ALL prompts (YOLO mode) | Used in trusted/sandbox environments only |
| `--from-pr N` | Open session linked to PR | `claude --from-pr 123` |
| `-w` / `--worktree` | Start in an isolated git worktree | `claude -w` |
| `--bare` | Scripted mode: skip hooks, LSP, plugins | For CI/automation |
| `--debug` | Enable debug logging | When things break |
| `--init` | Initialize project with CLAUDE.md | One-time project setup |

### Non-interactive one-liners

```bash
# Single query, clean text output
claude -p "explain the auth flow in this repo"

# Structured JSON for scripting
claude -p "find unused exports" --output-format json

# Pipe input into Claude
cat error.log | claude -p "analyze this and suggest a fix"
```

---

## Slash Commands (In-Session)

Type `/` at the start of a message to see all available. Grouped here by purpose.

### Context management

| Command | Purpose |
|---|---|
| `/clear` | Wipe conversation history; start fresh |
| `/compact [focus]` | Summarize history to free up tokens. Optional: `/compact focus on tests` |
| `/context` | Show context window usage with suggestions |
| `/resume [N or name]` | Resume a previous conversation |
| `/rename <name>` | Name the current session |
| `/branch` | Branch conversation for parallel exploration |
| `/rewind` | Revert to a checkpoint (or press `Esc` twice) |
| `/export` | Export conversation transcript |

### Models & settings

| Command | Purpose |
|---|---|
| `/model [name]` | View or switch models: `/model opus`, `/model sonnet`, `/model haiku` |
| `/effort [level]` | Set effort: `low`, `medium`, `high`, `xhigh` (Opus 4.7 only) |
| `/fast` | Toggle fast output mode |
| `/config` | Open settings interface |
| `/permissions` | Manage permissions interactively |
| `/status` | View session state |
| `/cost` | Token usage and estimated cost |
| `/theme` | Change syntax theme |

### Modes

| Command | Purpose |
|---|---|
| `/plan [task]` | Enter Plan Mode (read-only analysis) |
| `/init` | Initialize project: scans codebase, generates CLAUDE.md |

### Project-specific

| Command | Purpose |
|---|---|
| `/add-dir <path>` | Add working directory to expand file access |
| `/mcp` | Manage MCP servers: `/mcp enable`, `/mcp disable`, `/mcp list` |
| `/hooks` | View hook configuration |
| `/agents` | Manage subagents |
| `/memory` | View auto-memory files |
| `/security-review` | Scan for security vulnerabilities |
| `/simplify` | Review for simplification opportunities |

### Utility

| Command | Purpose |
|---|---|
| `/copy [N]` | Copy code blocks from latest response (or Nth-latest) |
| `/bashes` | List background bash tasks |
| `/tasks` | List background agents |
| `/doctor` | Check installation health |
| `/bug` | Report a bug to Anthropic |
| `/release-notes` | Browse version changelogs |
| `/powerup` | Interactive feature tutorials |
| `/voice` | Toggle push-to-talk mode |
| `/loop 5m /foo` | Run a command every 5 minutes |

---

## Keyboard Shortcuts

### General controls

| Shortcut | Action |
|---|---|
| `Ctrl+C` | Cancel current operation (two quick presses to force-exit) |
| `Ctrl+D` | Exit session (EOF) |
| `Ctrl+L` | Clear screen (keeps history) |
| `Ctrl+R` | Search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background current operation |
| `Ctrl+X` then `Ctrl+K` | Stop all running agents |
| `Ctrl+S` | Stash prompt draft |
| `Ctrl+G` | Open external editor (uses `$EDITOR`) |
| `Esc Esc` | Rewind last change |
| `Tab` | Accept prompt suggestion |
| `Shift+Tab` | Cycle permission modes (default → acceptEdits → auto → plan) |
| `Alt+P` / `Option+P` | Switch models mid-input |
| `Alt+T` | Toggle thinking mode |
| `Up` / `Down` | Navigate command history |
| `?` | Show all shortcuts |

### Multi-line input

| Method | Keys |
|---|---|
| Escape newline | `\` then `Enter` |
| macOS default | `Option+Enter` |
| Ghostty (your setup) | `Shift+Enter` |
| Universal fallback | `Ctrl+J` |

Run `/terminal-setup` once if multiline entry isn't working.

> **Mac keyboard note:** `Alt` is the key labeled `Option` (⌥). Claude Code's docs sometimes use both names interchangeably.

---

## Quick Prefixes

At the start of your message, these prefixes change behavior:

| Prefix | Meaning | Example |
|---|---|---|
| `/` | Slash command | `/clear` |
| `!` | Execute bash directly (no Claude roundtrip) | `! git status` |
| `#` | Add to persistent memory | `# Always use TypeScript strict mode` |
| `@` | Reference a file or directory | `@src/index.ts fix the type error` |
| `&` | Send task to cloud agent (async) | `& Build a landing page for X` |

The `#` prefix is the fastest way to give Claude persistent preferences without editing CLAUDE.md. The `@` prefix brings a specific file into context precisely (instead of Claude guessing).

---

## Permission Modes

Controls how aggressively Claude runs tools without asking.

| Mode | Behavior | Use Case |
|---|---|---|
| `default` | Prompts on first use of each tool | Normal development |
| `acceptEdits` | Auto-approves file edits, still prompts for bash | Trusted codebase |
| `auto` | Classifier model reviews each action | Autonomous with safeguards |
| `plan` | Read-only: no edits, no execution | Analysis before changes |
| `bypassPermissions` | No prompts at all | CI/CD, sandboxed environments |

Cycle with `Shift+Tab` during a session. The bottom status bar shows the current mode.

### Auto Mode (recommended)

Released in v2.1.85+, Auto Mode is the sane middle-ground:
- Read-only ops and file edits: auto-approved
- Dangerous ops (curl-pipe-bash, force-push to main, prod deploys, mass deletes): auto-blocked
- Everything in between: classifier model (Sonnet 4.6) decides
- Circuit breaker: 3 consecutive blocks or 20 total pauses back to manual prompting

```bash
claude --enable-auto-mode
```

---

## CLAUDE.md (Project Instructions)

The single most important file for Claude Code effectiveness. Claude reads it at the start of every session.

### Where to put it

| Location | Scope |
|---|---|
| `CLAUDE.md` (project root) | Everyone working in this project |
| `.claude/CLAUDE.md` | Same, alternative path |
| `~/.claude/CLAUDE.md` | Personal, applies to all your projects |

### What to include

Keep it scannable. Every word costs context tokens on every session.

```markdown
# Project Name

## Stack
- Backend: FastAPI, Python 3.13
- Frontend: React + TypeScript + Tailwind
- DB: Postgres 16 (Docker locally)

## Commands
- Dev: `npm run dev`
- Test: `npm test`
- Lint: `npm run lint`
- Migrate: `docker-compose exec api alembic upgrade head`

## Conventions
- Conventional commits (feat:, fix:, docs:, etc.)
- Never force-push to main
- Always run tests before committing

## Key Files
- src/server.ts: Express entrypoint
- src/models/: Drizzle ORM schemas
- src/routes/: API routes

## Dont
- Use `any` types
- Commit to main directly
- Add new dependencies without confirming
```

### Generate one automatically

```bash
claude --init
# or inside a session:
/init
```

Claude scans the codebase, asks clarifying questions, produces a CLAUDE.md.

---

## Settings Files

Layered from highest to lowest precedence. First match wins.

| Level | Path | Scope |
|---|---|---|
| Enterprise | `/Library/Application Support/ClaudeCode/managed-settings.json` | Locked by admins |
| CLI flags | Command-line args | Current session only |
| Project local | `.claude/settings.local.json` | You, this project (gitignored) |
| Project shared | `.claude/settings.json` | Team, this project (committed) |
| User global | `~/.claude/settings.json` | All your projects |

### Example `~/.claude/settings.json`

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6",
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm run:*)",
      "Bash(git:*)",
      "Edit(src/**)"
    ],
    "deny": [
      "Read(.env*)",
      "Bash(rm -rf:*)",
      "Bash(sudo:*)"
    ],
    "ask": [
      "WebFetch",
      "Bash(docker:*)"
    ],
    "defaultMode": "acceptEdits"
  },
  "includeCoAuthoredBy": true,
  "respectGitignore": true,
  "language": "en"
}
```

### Permission rule syntax

`Tool(pattern:*)` is a prefix match. `Bash(npm run test:*)` allows `npm run test`, `npm run test:unit`, `npm run test:e2e`, etc.
File patterns use glob: `Edit(src/**)`.

---

## Hooks

Shell commands that run at specific points in Claude's lifecycle. Great for formatting, linting, safety checks.

### Common hook events

| Event | When | Can Block? |
|---|---|---|
| `PreToolUse` | Before a tool runs | Yes |
| `PostToolUse` | After a tool runs | No |
| `UserPromptSubmit` | User sends a prompt | Yes |
| `Stop` | Claude finishes a response | Yes |
| `SessionStart` | Session opens | No |
| `SessionEnd` | Session closes | No |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle | Partial |
| `PreCompact` / `PostCompact` | Context compaction | No |
| `PermissionDenied` | Auto mode denies an action | No |

### Example: auto-format on save

In `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$FILE_PATH\""
          }
        ]
      }
    ]
  }
}
```

### Matcher syntax

| Pattern | Matches |
|---|---|
| `*` | All tools |
| `Bash` | Bash tool only |
| `Edit\|Write` | Edit OR Write (regex OR) |
| `mcp__github` | MCP server tools prefixed with `github` |

### Exit codes from hooks

| Code | Meaning |
|---|---|
| `0` | Success, operation proceeds |
| `2` | Block, stderr shown to Claude |
| `1`, `3+` | Non-blocking warning |

Use `"async": true` to run hooks in background without blocking.

---

## MCP Servers

MCP (Model Context Protocol) lets Claude connect to external services: databases, GitHub, Slack, your custom APIs.

### Add an MCP server

```bash
# HTTP server (most common now)
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# With auth headers
claude mcp add --transport http api https://api.example.com/mcp \
  --header "Authorization: Bearer $TOKEN"

# Local stdio server
claude mcp add --transport stdio postgres \
  --env "DATABASE_URL=postgresql://localhost/dev" \
  -- npx -y @anthropic-ai/mcp-server-postgres
```

### Scope

```bash
claude mcp add --scope user ...      # Just you (~/.claude.json)
claude mcp add --scope project ...   # Team (.mcp.json in repo)
```

### List & manage

```bash
claude mcp list                      # all configured servers
claude mcp remove <name>             # remove one
```

### In-session control

```
/mcp list          # browse available servers interactively
/mcp enable <n>    # enable one for this session
/mcp disable <n>   # disable
```

### Project-shared `.mcp.json`

Commit this to git so your teammates get the same integrations:

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    }
  }
}
```

---

## Subagents

Specialized Claude instances with their own context window. Used for parallel work or focused tasks.

### Built-in types

| Type | Default Model | Mode | Best For |
|---|---|---|---|
| **Explore** | Haiku (fast) | Read-only | Codebase search, understanding structure |
| **General-purpose** | Inherits main | Full read/write | Complex research + modifications |
| **Plan** | Inherits main | Read-only | Planning before execution |
| **Custom** | Configurable | Configurable | Domain-specific (security, testing, etc.) |

### Invoke manually

```
> use the explore agent to find all auth-related files
> have a subagent analyze the database schema and summarize it
```

Up to 10 subagents can run in parallel.

### Custom subagent definition

File: `.claude/agents/security-reviewer.md`

```markdown
---
name: security-reviewer
description: Expert security reviewer. Use PROACTIVELY after auth or data-handling changes.
tools: Read, Grep, Glob, Bash
model: opus
permissionMode: plan
---

You are a senior security engineer. Analyze for OWASP Top 10 vulnerabilities,
hardcoded secrets, and SQL injection. Report findings with severity levels and
remediation steps.
```

Now Claude can delegate to it, or you can:

```
> have the security-reviewer agent check the new auth module
```

---

## Models & Cost

### Current models (as of April 2026)

| Model | Input ($ / 1M) | Output ($ / 1M) | Use For |
|---|---|---|---|
| **Opus 4.7** | $5.00 | $25.00 | Flagship. Hard reasoning, architecture, agentic loops |
| **Sonnet 4.6** | $3.00 | $15.00 | Balanced daily driver |
| **Haiku 4.5** | $1.00 | $5.00 | Exploration, simple edits, subagents |

Typical session: 50K-200K input + 10K-50K output tokens. Sonnet runs ~$0.30-$1.50 per session; Opus ~$0.50-$2.25.

### Switching models mid-session

```
/model opus            # upgrade for hard task
/model sonnet          # back to default
/model haiku           # downgrade for exploration
/effort xhigh          # Opus 4.7: max reasoning for coding
```

### Decision rules

- **Default to Sonnet 4.6** for normal coding
- **Switch to Opus 4.7** when Sonnet's answer feels shallow, for architecture work, or for security/reasoning-heavy tasks
- **Use Haiku 4.5** for exploration subagents, grep-like tasks, simple renames

### Default model by plan

| Plan | Default |
|---|---|
| Max, Team Premium | Opus 4.7 |
| Pro, Team Standard | Sonnet 4.6 |
| Enterprise, API | Sonnet 4.6 (switches to Opus 4.7 on Apr 23, 2026) |

---

## Common Workflows

### Quick questions without cluttering a session

```bash
claude -p "what does this regex match: ^[a-z][a-z0-9_-]*$"
claude -p "grep for any hardcoded API keys in this repo"
```

### Resume where you left off

```bash
claude -c                         # continue most recent
claude -r "feature-auth"          # continue a specific named session
claude -r -                       # list all sessions
```

### Feature development

```bash
claude -n "add-oauth"             # start and name the session
> /plan add OAuth login with Google as the provider
# Claude asks clarifying questions, writes a plan
# Review, edit, then:
> implement the plan
```

### Code review of current branch

```bash
claude -p "review the diff from main against this branch. Focus on security and perf." --output-format text
```

### Refactor with Plan mode first

```
/plan refactor src/db/ to use transactions consistently
# Claude produces a plan WITHOUT making changes
# Review it, then:
> looks good, go ahead
```

### Running in an isolated worktree

```bash
claude -w
# Claude creates a separate git worktree, works there
# Merge back when satisfied
```

### Batch-processing files

```bash
fd -e ts -e tsx . src/ | xargs -I{} claude -p "add JSDoc comments to {}" --max-turns 3
```

### Integrate with your PR workflow

```bash
claude --from-pr 123
# Opens a session with PR 123's context loaded
```

---

## Tips & Gotchas

### `/clear` often

Stale context is expensive and degrades response quality. Start fresh between unrelated tasks.

### Use `/compact` before long sessions hit limits

When the bottom bar shows context usage above 70%, compact instead of continuing; Claude summarizes the conversation so far, freeing tokens.

### `CLAUDE.md` is the biggest force multiplier

Spend 30 minutes writing a good one. You'll save that much context and get better answers on every subsequent session.

### Plan mode → then implement

For any non-trivial change, use `/plan` first. You get a review step before Claude burns tokens making wrong edits.

### `!` for fast shell

`! git status` runs bash without Claude interpreting it. Saves tokens for things you already know how to do.

### `@` over "the file" references

"Fix the auth file" makes Claude search. `@src/auth.ts fix the type error` goes straight to the file. Faster, cheaper, more accurate.

### `--dangerously-skip-permissions` is real but not forever

Useful in Docker sandboxes or for trusted, short-lived sessions. Don't set it as default. Auto Mode is the sane alternative for daily work.

### Hooks for guardrails

Instead of remembering to run prettier/eslint after every change, hook them to `PostToolUse(Edit|Write)`. Applies automatically, no cost to your context.

### Running inside your dotfiles repo

You can use Claude Code directly on this repo:

```bash
cd ~/dotfiles
claude
> analyze my setup and suggest improvements
> update the README to reflect [change]
> add a cheat sheet for [tool]
```

### Check cost before expensive runs

`/cost` shows how much the current session has used. Run it after a long back-and-forth to sanity-check.

### Compare with Cursor CLI

Both are agentic CLIs for code. See the [Cursor CLI cheat sheet](cursor-cli-cheatsheet.md) for the comparison. Rule of thumb: **Claude Code for multi-file cross-repo tasks and agentic loops; Cursor CLI for tightly integrated editor-adjacent workflows.**
