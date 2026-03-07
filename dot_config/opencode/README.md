# opencode config

Personal configuration for [opencode](https://opencode.ai) — an AI coding
assistant. This repo wires up MCP servers, custom AI agents, and a slash
command used daily for code review.

## What's here

```
opencode.json       → MCP servers, providers, and agent model assignments
agent/              → Custom agent system prompts
command/            → Slash commands (invoked as /command-name)
```

## MCP servers

| Server       | Type   | Purpose                                        |
| ------------ | ------ | ---------------------------------------------- |
| `context7`   | remote | Up-to-date library docs and code examples      |
| `exa`        | remote | Web search                                     |
| `telecontext`| remote | Internal Telekom tools (GitLab, Jira, etc.)    |
| `morph`      | local  | Fast grep via `warp_grep`                      |
| `azure`      | local  | Azure resource management (read-only mode)     |

## Agents

Agents extend opencode with specialist personas. Each lives in `agent/`
as a Markdown file with a YAML frontmatter block that sets its description,
model, permissions, and visibility.

| Agent               | Purpose                                                  |
| ------------------- | -------------------------------------------------------- |
| `docs`              | Technical documentation (Google doc principles)         |
| `review`            | Senior-level code review; delegates security to ↓       |
| `security-review`   | Deep security and vulnerability analysis (hidden)        |
| `mermaid`           | Mermaid diagram generation (hidden)                      |
| `platform-engineer` | Azure platform / IaC / GitOps orchestrator               |
| `platform-architect`| Architecture decisions and trade-off analysis (hidden)  |
| `platform-iac`      | Bicep and Terraform implementation (hidden)              |
| `platform-gitops`   | GitLab CI/CD pipelines and GitOps workflows (hidden)     |

Hidden agents are sub-agents: they are only invoked by other agents via
`@agent-name`, not surfaced directly in the UI.

The `platform-engineer` agent is the entry point for any Azure /
IaC / GitOps work. It delegates to the three hidden platform sub-agents
and coordinates the full delivery lifecycle.

## Slash commands

| Command   | Description                      |
| --------- | -------------------------------- |
| `/review` | Run code review via `@review`    |

## Model assignments

```jsonc
// opencode.json (excerpt)
"agent": {
  "build":             "github-copilot/gpt-5.3-codex",
  "plan":              "github-copilot/claude-sonnet-4.6",
  "review":            "github-copilot/claude-sonnet-4.6",
  "docs":              "github-copilot/claude-sonnet-4.6",
  "security-review":   "azure-anthropic/claude-opus-4-6",
  "platform-engineer": "github-copilot/claude-sonnet-4.6",
  "platform-architect":"azure-anthropic/claude-opus-4-6",
  "platform-iac":      "github-copilot/claude-sonnet-4.6",
  "platform-gitops":   "github-copilot/claude-sonnet-4.6"
}
```

Security and architecture agents use Claude Opus (via Azure AI Foundry)
because those tasks benefit from deeper reasoning.

## See also

- [opencode documentation](https://opencode.ai/docs)
- [opencode agent configuration](https://opencode.ai/docs/agents)
- [opencode MCP configuration](https://opencode.ai/docs/mcp)
