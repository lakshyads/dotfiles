---
name: pr-description
description: Formats GitHub pull request titles (Conventional Commits style) and bodies (Summary/Changes/Why/Test plan). Use when drafting a pull request title or description, or running `gh pr create`.
---

# Pull Request Descriptions

If the repository has a PR template (`.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/`), fill that in instead of the structure below.

**Title**: the same format as a commit subject, per the `commit-message` skill (including the Jira ID prefix when the branch has one).

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
- Use `#` for the top-level sections (Summary, Changes, Why, Test plan) and `##` only for subsection groupings within a section.
- No emojis and no "Generated with" footer lines.
- When showing a draft in chat, wrap the whole body in a fenced ` ```markdown ` block so the raw `#` syntax stays visible and copyable. Pass the body to `gh pr create --body` (or a body file) unfenced, so GitHub renders it.
