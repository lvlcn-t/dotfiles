# Adding a new agent

An agent is a Markdown file in `agent/` with a YAML frontmatter block that
defines its identity, model, and tool permissions. opencode reads this file
to register the agent and pass its body as the system prompt.

## Create the agent file

Add a file at `agent/<your-agent-name>.md`. The filename becomes the agent's
identifier in the UI and in `@mentions`.

The frontmatter must include `name`, `description`, and `model` — these are
enforced by the [markdown linter](linting.md). All other keys are optional.

```markdown
---
name: my-agent
description: One sentence: what this agent does and when to invoke it.
model: github-copilot/claude-sonnet-4.6
---

Your system prompt goes here.
```

## Frontmatter reference

| Key           | Required | Description                                                 |
| ------------- | -------- | ----------------------------------------------------------- |
| `name`        | yes      | Agent identifier; must match the filename stem              |
| `description` | yes      | Shown in the UI; also passed to the model as context        |
| `model`       | yes      | Model to use (see model options below)                      |
| `color`       | no       | Hex color shown in the UI (e.g. `"#22c55e"`)                |
| `hidden`      | no       | `true` hides the agent from the UI; invoke via `@name` only |
| `mode`        | no       | `subagent` marks it as a delegate; pair with `hidden: true` |
| `permission`  | no       | Tool permission overrides (see below)                       |

### Model options

| Model                              | Use for                                |
| ---------------------------------- | -------------------------------------- |
| `github-copilot/claude-sonnet-4.6` | General-purpose; default choice        |
| `azure-anthropic/claude-opus-4-6`  | Deep reasoning: security, architecture |
| `github-copilot/gpt-5.3-codex`     | Code generation and transformation     |

### Permissions

By default agents inherit opencode's global tool settings. Use `permission` to
tighten or loosen access:

```yaml
permission:
  edit: deny           # deny a tool entirely
  write: allow         # allow unconditionally
  webfetch: allow
  bash:
    "*": ask           # ask for any bash command ...
    "git diff": allow  # ... except these specific ones
    "git log*": allow
  task:
    security-review: allow  # allow delegating to another agent
```

Agents that delegate to sub-agents must explicitly grant `task: <agent>: allow`
for each sub-agent they intend to call.

## Write the system prompt

The file body (after the closing `---`) is the system prompt. Keep it focused:
one agent, one responsibility. If you find yourself writing "and also…",
consider whether the second responsibility belongs in its own sub-agent.

Use `@agent-name` references in the description and prompt to signal delegation
points. Cross-reference the
[opencode agent docs](https://opencode.ai/docs/agents) for supported prompt
patterns.

## See also

- [Markdown linting](linting.md)
- [opencode agent configuration](https://opencode.ai/docs/agents)
