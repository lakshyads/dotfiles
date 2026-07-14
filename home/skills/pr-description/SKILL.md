---
name: pr-description
description: Formats GitHub pull request titles (Conventional Commits style) and bodies (Summary/Changes/Why/Test plan, wrapped in a markdown code block). Use this skill whenever drafting or writing up a pull request description/title, or running `gh pr create`.
---

# Pull Request Descriptions

**Title**: same Conventional Commits format as the commit subject line.

**Body** - use `#` for top-level section headings and `##` for subsection headings. Structure:

```
# Summary
- bullet: one concrete change per line

# Changes

## Subsection label (e.g. Content, Infrastructure, Frontend)
- bullet
- bullet

## Another subsection
- bullet

# Why
One short paragraph. Omit if the title makes it obvious.

# Test plan
- [ ] specific thing to verify
- [ ] specific thing to verify
```

Rules:
- Always use `#` for top-level sections (Summary, Changes, Why, Test plan) - never `##` for these, as `##` renders as bold text rather than a heading in many tools
- Use `##` only for subsection groupings within a section
- No emojis, no em-dashes
- No "Generated with" footer lines
- ALWAYS wrap the entire PR description body in a fenced markdown code block (` ```markdown `) when outputting it, so the raw `#` syntax is visible and copyable rather than being rendered
