# Markdown linting

Two-layer markdownlint setup enforces consistent style across the repo and
validates agent frontmatter fields.

## How it works

```text
.markdownlint.yaml                  ← repo-wide rules (root)
dot_config/opencode/
  .markdownlint-cli2.yaml           ← opencode-scoped overrides + custom rule
  agent-frontmatter.cjs             ← custom rule: required frontmatter fields
```

The root config sets baseline rules for every Markdown file in the repo.
The opencode config extends those rules and adds an additional check specific
to agent files: all `agent/*.md` files must have `name`, `description`, and
`model` frontmatter keys.

## Run the linter

```bash
# Lint only the opencode directory (picks up .markdownlint-cli2.yaml)
markdownlint-cli2 "dot_config/opencode/**/*.md"

# Lint the whole repo (uses root .markdownlint.yaml)
markdownlint-cli2 "**/*.md"
```

## Root config rules

File: `.markdownlint.yaml`

| Rule  | Setting              | Effect                                           |
| ----- | -------------------- | ------------------------------------------------ |
| MD003 | `atx`                | ATX-style headings only (`##`, not underline)    |
| MD004 | `dash`               | Unordered lists use `-`                          |
| MD007 | `indent: 2`          | List indent is 2 spaces                          |
| MD013 | `80`, `strict: true` | 80-char line limit; skips code blocks and tables |
| MD022 | `true`               | Blank lines required around headings             |
| MD029 | `ordered`            | Ordered lists must use `1. 2. 3.`                |
| MD033 | `true`               | No inline HTML                                   |
| MD034 | `true`               | No bare URLs                                     |
| MD040 | `true`               | Fenced code blocks must declare a language       |
| MD041 | `true`               | First line must be a top-level heading           |
| MD046 | `fenced`             | Code blocks must use fences, not indentation     |

## Opencode overrides

File: `dot_config/opencode/.markdownlint-cli2.yaml`

- **`MD041: false`** — agent files start with YAML frontmatter, not a heading.
- **`agent-frontmatter-fields`** — custom rule requiring `name`, `description`,
  and `model` keys in every `agent/*.md` file.

## Custom rule: agent-frontmatter-fields

File: `dot_config/opencode/agent-frontmatter.cjs`

Applies only to files matching `agent/*.md`. Reports an error at line 1 if any
of the required frontmatter fields are missing or if the frontmatter block is
absent entirely.

Required fields (configurable via `required_fields` in the config):

- `name` — agent identifier used by opencode
- `description` — shown in the UI and passed to the model as context
- `model` — the model the agent runs on

To disable the rule for a specific run:

```yaml
# in .markdownlint-cli2.yaml
config:
  agent-frontmatter-fields: false
```

## See also

- [Adding a new agent](adding-an-agent.md)
- [markdownlint rules reference][ml-rules]
- [markdownlint-cli2 config docs][ml-cli2]

[ml-rules]: https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md
[ml-cli2]: https://github.com/DavidAnson/markdownlint-cli2#configuration
