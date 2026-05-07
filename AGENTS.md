# manuals

Architecture decisions, changelogs, and reference documentation for the V-Sekai-fire multiplayer fabric stack. Published as a Quarto website.

## Build

```sh
uv sync           # install Python deps
quarto render     # build to _site/
quarto preview    # local preview
```

## Adding a decision

Create a Markdown file in `decisions/` named `YYYYMMDD-short-title.md` with frontmatter:

```markdown
---
title: Short title
date: YYYY-MM-DD
status: accepted | proposed | deprecated | superseded
---

## Context

## Decision

## Consequences
```

## Adding a changelog entry

```sh
elixir create_changelog_entry.exs        # uses today's date
elixir create_changelog_entry.exs 20260512
```

## Key files

| Path                         | Purpose                       |
| ---------------------------- | ----------------------------- |
| `_quarto.yml`                | Site config                   |
| `index.md`                   | Landing page                  |
| `decisions/`                 | Architecture Decision Records |
| `decisions.qmd`              | ADR index                     |
| `changelog/`                 | Changelog entries by year     |
| `changelog.qmd`              | Changelog index               |
| `create_changelog_entry.exs` | Generate new changelog entry  |

## Conventions

- Decision filenames: `YYYYMMDD-kebab-title.md`
- Changelog filenames: `YYYYMMDD-deck-log.md` inside `changelog/YYYY/`
- Do not commit `_site/` — it is build output
- Commit style: sentence case, no `type(scope):` prefix
