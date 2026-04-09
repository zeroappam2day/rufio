# Rufio User Guide

Your setup: Windows 11, PowerShell, Ollama local + OpenRouter cloud. No Docker. No WSL.

## What You Have

- **ruflo v3.5.78** — AI agent orchestration CLI
- **Ollama** — local LLM (qwen3:8b) + embeddings (nomic-embed-text)
- **OpenRouter** — cloud LLM fallback (nvidia/nemotron-3-super-120b-a12b:free)
- **Hybrid memory** — sql.js + HNSW vector search, 384-dim ONNX embeddings
- **MCP server** — persistent via pm2, 310+ tools available
- **Hive-mind** — byzantine consensus, mesh topology, 15 agents max

## Quick Start (Every New Session)

```powershell
# 1. Restore MCP server
pm2 resurrect
pm2 list                          # confirm ruflo-mcp is online

# 2. Init swarm
npx ruflo@latest swarm init --v3-mode

# 3. Spawn agents
npx ruflo@latest agent spawn -t coder
npx ruflo@latest agent spawn -t researcher
```

## Core Commands

### Agents

```powershell
npx ruflo@latest agent spawn -t <type>          # spawn agent
npx ruflo@latest agent spawn -t coder --provider openrouter --model nvidia/nemotron-3-super-120b-a12b:free
npx ruflo@latest agent list                      # list active agents
npx ruflo@latest agent status <agent-id>         # agent details
npx ruflo@latest agent stop <agent-id>           # kill agent
```

Agent types: `coder`, `researcher`, `tester`, `planner`, `analyst`, `reviewer`, `optimizer`, `documenter`, `security-architect`, `security-auditor`

### Swarm

```powershell
npx ruflo@latest swarm init --v3-mode            # init with defaults
npx ruflo@latest swarm status                    # check swarm
npx ruflo@latest swarm stop                      # stop swarm
```

### Memory

```powershell
npx ruflo@latest memory store --key "name" --value "data" --namespace patterns
npx ruflo@latest memory search --query "search text"
npx ruflo@latest memory list
npx ruflo@latest memory stats
npx ruflo@latest memory export --format sql --output export.sql
```

### Doctor & Health

```powershell
npx ruflo@latest doctor                          # health check
npx ruflo@latest doctor --fix                    # auto-fix issues
```

### Providers

```powershell
npx ruflo@latest providers list                  # show configured providers
npx ruflo@latest providers test --all            # test connectivity
```

### Hive-Mind (Multi-Agent Consensus)

```powershell
# Init via MCP (hive-mind init has a CLI bug — use mcp exec)
npx ruflo@latest mcp exec --tool hive-mind_init --args '{"topology":"mesh","consensus":"raft","maxAgents":15}'

npx ruflo@latest hive-mind status
npx ruflo@latest hive-mind spawn "objective text"
```

### Daemon / MCP Server

```powershell
pm2 list                                         # check MCP status
pm2 restart ruflo-mcp                            # restart
pm2 logs ruflo-mcp                               # view logs
pm2 save                                         # persist config
```

The MCP server is the persistent process. `daemon start` is one-shot (runs and exits).

### Hooks & Learning

```powershell
npx ruflo@latest hooks pretrain                  # bootstrap learning system
npx ruflo@latest hooks intelligence --status     # check intelligence layer
npx ruflo@latest neural train -p coordination    # train agent patterns
npx ruflo@latest embeddings warmup               # preload embedding model
```

### Tasks

```powershell
npx ruflo@latest task create --name "task-name" --description "what to do"
npx ruflo@latest task list
npx ruflo@latest task status <task-id>
```

## Config Files

| File | Purpose | Danger |
|------|---------|--------|
| `.env` | API keys, env vars | Never commit. Gitignored. |
| `.mcp.json` | MCP server config for Claude Code | **Overwritten by any `init --force`** |
| `.claude-flow/config.yaml` | Runtime config (topology, memory, neural) | Overwritten by reinit |
| `claude-flow.config.json` | Agent config (providers, HNSW, vectors) | Auto-generated |
| `claude_desktop_config.json` | Claude Desktop MCP entries | At `%APPDATA%\Claude\` |

## Critical Rules

1. **Never use `--force` on init commands** without backing up `.mcp.json` first. It rewrites 115 files.
2. **`npx ruflo@latest` runs from a separate npm cache** — packages in your project's `node_modules` are invisible to it.
3. **The `--provider` flag on `agent spawn` is accepted but not actively used** for LLM routing. Configure providers via `providers configure` instead.
4. **HNSW "Available: No" is cosmetic** — it shows "No" on cold status checks but works during actual memory operations.
5. **Free model endpoints disappear without notice.** Always test with a real API call before building workflows.
6. **After any reinit**, check and restore `.mcp.json` env vars (OLLAMA_URL, OPENROUTER_API_KEY, etc.)

## Your LLM Stack

| Provider | Model | Use Case | Cost |
|----------|-------|----------|------|
| Ollama (local) | qwen3:8b | Primary — fast, private, GPU | Free |
| Ollama (local) | nomic-embed-text | Embeddings (384-dim) | Free |
| OpenRouter | nvidia/nemotron-3-super-120b-a12b:free | Cloud fallback — heavy tasks | Free |
| OpenRouter | qwen/qwen3.6-plus | Premium cloud | Paid |

## File Layout

```
227_rufio/
  .env                          # API keys (gitignored)
  .mcp.json                     # MCP server config
  .gitignore                    # excludes .env, .swarm/, *.db
  .claude-flow/
    config.yaml                 # runtime config
    data/                       # memory persistence
    neural/
      patterns.json             # trained coordination patterns
  .swarm/
    memory.db                   # SQLite + HNSW vector database
  scripts/
    start-daemon.ps1            # pm2 restore instructions
  state/
    plan.json                   # execution plan
  docs/                         # this guide lives here
```
