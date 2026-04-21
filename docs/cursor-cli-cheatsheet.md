# Cursor CLI Cheat Sheet

Reference for Cursor CLI (the terminal companion to the Cursor editor). Current as of April 2026, covering Agent Modes, Cloud Handoff, MCP integration, and Subagents (Cursor 2.4+).

Official docs: <https://cursor.com/docs/cli>

---

## Table of Contents

- [Installation & First Run](#installation--first-run)
- [Command Name](#command-name)
- [CLI Flags](#cli-flags)
- [Agent Modes](#agent-modes)
- [Slash Commands](#slash-commands)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Prompt Prefixes](#prompt-prefixes)
- [Cloud Handoff](#cloud-handoff)
- [MCP Integration](#mcp-integration)
- [Rules & Skills](#rules--skills)
- [Subagents](#subagents)
- [Models](#models)
- [Non-Interactive / Scripting](#non-interactive--scripting)
- [Common Workflows](#common-workflows)
- [Tips & Gotchas](#tips--gotchas)

---

## Installation & First Run

You installed Cursor CLI from within the Cursor editor (it offers a one-click install). To install manually:

```bash
curl https://cursor.com/install -fsSL | bash
```

After install, run `/setup-terminal` once to configure multiline input for your terminal:

```bash
agent
> /setup-terminal
```

This auto-configures `Option+Enter` for Apple Terminal, Alacritty, or VS Code. For iTerm2, Ghostty, Kitty, Warp, and Zed, `Shift+Enter` works out of the box.

---

## Command Name

As of the 2026 rename: **`agent`** is the primary command. `cursor-agent` still works for backward compatibility.

```bash
agent                    # start interactive session (modern)
cursor-agent             # same thing (legacy)
```

The rest of this doc uses `agent`.

---

## CLI Flags

Starting Cursor Agent with flags:

| Flag | Description | Example |
|---|---|---|
| `agent` | Start interactive session | |
| `-p "prompt"` | Print mode: run once, exit | `agent -p "review the diff"` |
| `--resume [id]` | Resume a specific or recent thread | `agent --resume abc123` |
| `resume` (subcommand) | Resume most recent conversation | `agent resume` |
| `-continue` | Shorthand for `--resume=-1` (resume latest) | `agent -continue` |
| `ls` | List previous conversations | `agent ls` |
| `--mode=MODE` | Start in a specific agent mode | `agent --mode=plan` |
| `--model MODEL` | Override default model | `agent --model claude-sonnet-4-6` |
| `--output-format FMT` | `text`, `json`, or `stream-json` | `agent -p "audit" --output-format json` |
| `--stream-partial-output` | Stream partial results (use with `stream-json`) | `agent -p "fix" --output-format stream-json --stream-partial-output` |
| `--force` | Auto-apply changes, skip confirmations | `agent -p "fix" --force` |
| `--yolo` | Approve workspace trust, skip MCP confirmations | For sandboxed runs |
| `--api-key KEY` | Use a specific API key | Or set `CURSOR_API_KEY` env var |

### Non-interactive (scripting)

```bash
# Plain text output
agent -p "find and describe security issues" --output-format text

# Structured JSON for parsing
agent -p "list all imports used but never called" --output-format json

# Streaming output in scripts
agent -p "refactor src/utils.ts" --output-format stream-json --stream-partial-output
```

> **Critical:** Non-interactive mode requires a real TTY. Running `agent -p "..."` in a subprocess or without a TTY will hang indefinitely. For true automation (CI, background scripts), pipe through tmux or use `--output-format stream-json` through a pseudo-terminal wrapper.

---

## Agent Modes

Three modes, switchable mid-session or at startup. Similar to Claude Code's permission modes but focused on intent.

| Mode | Behavior | Trigger |
|---|---|---|
| **Agent** (default) | Full read/write + command execution | Default |
| **Plan** | Design approach first; asks clarifying questions | `/plan` or `--mode=plan` |
| **Ask** | Explore the code without making changes | `/ask` or `--mode=ask` |

### Starting in a mode

```bash
agent --mode=plan              # arrive in Plan mode
agent --mode=ask               # arrive in Ask mode
```

### Switching mid-session

```
/plan refactor the auth module to use passport.js
/ask what does the retry logic in api-client do
```

Agents can also proactively request switching modes mid-conversation when they detect a different mode would be more effective. You can auto-approve or auto-reject these transitions in settings.

---

## Slash Commands

Type `/` to see all available. Grouped here by purpose.

### Context & session

| Command | Purpose |
|---|---|
| `/resume` | Browse all prior conversations (sorted by last interaction) |
| `/branch` | Branch conversation for parallel exploration |
| `/clear` | Clear conversation history |
| `/compact` | Condense history to free tokens |
| `/context` | Show context window usage |

### Modes & models

| Command | Purpose |
|---|---|
| `/plan [task]` | Enter Plan mode |
| `/ask [question]` | Enter Ask mode (read-only exploration) |
| `/model` | View/switch models (replaces old `/models`) |
| `/max-mode [on\|off]` | Toggle max mode on models that support it |
| `/auto-run` | Toggle auto-run (skip command approval prompts) |

### Configuration

| Command | Purpose |
|---|---|
| `/rules` | Create/edit rules directly from CLI |
| `/mcp list` | Interactive MCP server menu |
| `/mcp enable <n>` | Enable a specific MCP server |
| `/mcp disable <n>` | Disable a specific MCP server |
| `/setup-terminal` | Auto-configure multiline keybindings |
| `/vim` | Toggle vim mode for the prompt editor |

### Utility

| Command | Purpose |
|---|---|
| `/about` | Show environment + CLI version details |
| `/usage` | View streaks and usage stats |
| `/login` / `/logout` | Authenticate / sign out |

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl+C` | Cancel current operation (improved detection prevents accidental exits) |
| `Ctrl+D` | Exit immediately on empty chat (standard shell behavior) |
| `Ctrl+R` | Review changes the agent made |
| `Shift+Tab` | Toggle auto-run (once per invocation) |
| `Enter` | Send message |
| `Up` / `Down` | Cycle through previous messages |
| `I` | Add follow-up instructions while agent is working |
| `Y` / `N` | Approve / reject pending command |

### Multiline input

| Method | Keys |
|---|---|
| iTerm2, Ghostty, Kitty, Warp, Zed | `Shift+Enter` |
| Apple Terminal, Alacritty, VS Code | `Option+Enter` (after running `/setup-terminal`) |
| Universal fallback | `Ctrl+J` or `\` then `Enter` |

Your Ghostty setup gets `Shift+Enter` for free. No configuration needed.

> **Mac keyboard note:** `Alt` = the `Option` (⌥) key. Cursor's docs use both names interchangeably.

---

## Prompt Prefixes

Special prefixes at the start of a message:

| Prefix | Meaning | Example |
|---|---|---|
| `/` | Slash command | `/plan` |
| `&` | Send to cloud agent (async, see below) | `& refactor the entire API layer` |
| `@` | Reference a file or context | `@src/auth.ts explain this logic` |

---

## Cloud Handoff

New in Jan 2026: push a conversation to a cloud agent that keeps running while you're away.

### Send a task to the cloud

Prepend `&` to any message:

```
& run the full test suite and summarize failures
```

Or:

```
& migrate all the useState hooks in src/components/ to Zustand
```

The conversation migrates to the cloud. You can close your terminal.

### Check on it later

- Web: <https://cursor.com/agents>
- Mobile: Cursor iOS/Android app

Pick up where it left off on any device. When the cloud agent finishes, it produces a PR or summary ready for review.

### When to use cloud handoff

- Long-running tasks (test suites, large refactors, codebase analysis)
- You need to close the laptop but want the work to continue
- Overnight tasks with a review waiting in the morning
- Tasks that may loop or require many iterations

---

## MCP Integration

Cursor CLI reads the same `mcp.json` configuration as the Cursor editor.

### Configuration locations

| File | Scope |
|---|---|
| `.cursor/mcp.json` | Project (checked into git) |
| `~/.cursor/mcp.json` | User-global |

### Example `mcp.json`

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/dev"
      }
    }
  }
}
```

### In-session management

```
/mcp list                    # browse, enable, configure
/mcp enable github
/mcp disable postgres
```

Cursor 2.4+ loads MCPs lazily; servers only spin up when the agent actually needs them, reducing token usage.

### One-click OAuth

The new MCP login flow handles OAuth callbacks automatically. When an MCP requires auth, Cursor opens a browser, completes the flow, and the agent gets access immediately. No manual token shuffling.

---

## Rules & Skills

Two ways to inject project-specific knowledge into the agent's context.

### Rules (always-on context)

Files in `.cursor/rules/` that are automatically loaded:

```
.cursor/rules/
├── typescript.md       # TS conventions for this project
├── security.md         # security requirements
└── api-style.md        # API design patterns
```

Manage with `/rules` to create or edit interactively.

The CLI also reads `AGENTS.md` and `CLAUDE.md` at project root (if present) and applies them as rules, so a well-written CLAUDE.md works for both tools.

### Skills (on-demand knowledge)

New in 2.4. Unlike rules, skills are discovered by the agent when relevant, or you invoke them via the slash menu.

Skills live in `.cursor/skills/` as `SKILL.md` files with custom commands, scripts, and procedural instructions. Good for workflows like "deploying to staging" or "running the data pipeline" that have specific steps.

### When to use which

- **Rule**: "always use semantic HTML" (always-on, declarative)
- **Skill**: "how to add a new API endpoint" (procedural, situational)

---

## Subagents

New in Cursor 2.4. Specialized agents handle discrete parts of a parent task, run in parallel, have their own context.

### Built-in subagents

Cursor ships defaults for:
- **Research**: codebase search and discovery
- **Terminal**: running shell commands
- **Parallel work**: coordinating multiple changes

These activate automatically; you don't need to manage them.

### Custom subagents

Define your own with custom prompts, tool access, and models. They run in parallel, keeping the main conversation focused.

Example use cases:
- A "security reviewer" subagent that runs after every code change
- A "test writer" subagent triggered when new functions are added
- A "performance analyzer" that benchmarks changes

---

## Models

As of April 2026, Cursor CLI supports frontier models from multiple providers:

- **Anthropic**: Claude Opus, Sonnet, Haiku (latest versions)
- **OpenAI**: GPT-4/5 variants
- **Google**: Gemini
- **Cursor**: in-house optimized variants

### Check available models

```
/model
```

Shows current model and switchable options.

### Switch mid-session

```
/model claude-opus-4-7
/model gpt-5
```

### Max mode

Some models support an enhanced "max mode" that prioritizes accuracy over speed:

```
/max-mode on
/max-mode off
```

---

## Non-Interactive / Scripting

Cursor CLI works in pipelines, CI, and automation.

### Basic scripting

```bash
# Plain output for logs
agent -p "audit src/ for security issues" --output-format text > audit.log

# Structured for parsing
agent -p "list TODOs with file:line references" --output-format json \
  | jq '.results[] | select(.priority == "high")'
```

### Authentication for CI

```bash
export CURSOR_API_KEY="$CURSOR_API_KEY"
agent -p "run security audit" --output-format json --force
```

### GitHub Actions integration

Cursor provides official GitHub Actions for automated code review, issue triage, and PR analysis. See <https://cursor.com/docs/cli/github-actions> for details.

### TTY requirement (critical)

Non-interactive mode still requires a real TTY. These will hang:

```bash
# ❌ Won't work: no TTY
agent "task" &
subprocess.run(["agent", "-p", "task"])
echo "task" | agent
```

Workaround for CI: use `tmux` to provide a pseudo-TTY.

```bash
# Example tmux wrapper
tmux new-session -d -s cursor 'agent -p "task" --output-format stream-json'
tmux capture-pane -p -t cursor
```

---

## Common Workflows

### Quick code question

```bash
agent -p "what does the retry logic in api-client.ts do"
```

### Plan a feature before implementing

```bash
agent
> /plan add OAuth with Google as provider
# Cursor asks clarifying questions, produces a plan
# When you're ready:
> implement the plan
```

### Resume work from yesterday

```bash
agent resume                  # most recent conversation
agent --resume abc123         # specific thread
agent ls                      # see all
```

### Long task while you sleep

```bash
agent
> & migrate all function components to use React Server Components
# Close the terminal, check the web UI in the morning
```

### Ask questions about the codebase

```bash
agent --mode=ask
> how does authentication flow through this app
> what database migrations have we run recently
```

### Integrate with Cursor editor

Open a file in the editor, use `Cmd+K` for inline edits. For anything larger, run `agent` from the terminal in the same repo. Both see the same workspace, same rules, same MCP servers.

### Review before merging

```bash
agent -p "review the diff from main. Flag any regressions or security issues." --output-format text
```

---

## Tips & Gotchas

### `agent` vs `cursor-agent`

Both work. `agent` is the modern canonical name. Update your muscle memory if you learned `cursor-agent` first.

### Ask mode is underrated

Before making changes, `agent --mode=ask` and explore the code first. You'll catch Cursor misunderstandings before they produce bad edits.

### `/setup-terminal` solves multiline pain

Run it once. If `Shift+Enter` or `Option+Enter` don't add newlines correctly, this fixes it.

### `Ctrl+R` for diffs is a killer feature

After an agent makes changes, `Ctrl+R` opens a precise word-level diff. Accept or reject inline.

### TTY-blindness is real

Any form of "run this in a subprocess" or "pipe input to agent" will freeze. Use `agent -p "..."` in a real terminal, or wrap via tmux for automation.

### Compare with Claude Code

Both are agentic CLIs. When to reach for which:

- **Cursor CLI**: editor-adjacent work, when you're already in the Cursor ecosystem, when you want cloud handoff for long tasks, when you want multi-model access
- **Claude Code**: multi-file cross-repo refactors, agentic loops with subagents, workflows built around hooks, when you specifically want Claude's models

See the [Claude Code cheat sheet](claude-code-cheatsheet.md) for its full reference.

### CLAUDE.md works for both

Since Cursor reads `CLAUDE.md` at project root as rules, a single file works as project instructions for either tool. No need to maintain duplicates.

### `&` cloud handoff is newer than it looks

It's useful beyond "long tasks." Send exploratory work to the cloud: `& survey all the testing frameworks in use across our repos`. You keep working; the cloud returns an answer asynchronously.

### Skills > commands for procedural knowledge

If you have a "how we deploy" runbook, put it in `.cursor/skills/deploy/SKILL.md`. The agent will discover and apply it when relevant, rather than always loading it.

### `/rules` from CLI saves round-trips

Instead of opening the editor to edit a rule file, `/rules` lets you manage them inside the running agent session. Faster for quick updates.
