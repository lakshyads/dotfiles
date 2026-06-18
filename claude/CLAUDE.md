# Global rules

## Commit messages

Write commit subjects as Conventional Commits with a scope:

```
<type>(<scope>): <short imperative summary>
```

- **type**: one of `feat`, `fix`, `refactor`, `chore`, `docs`, `deploy`, `test`, `perf`, `style`, `build`, `ci`.
- **scope**: the area touched, in parentheses, lowercase (e.g. `billing`, `vouchers`, `auth`, `i18n`, `infra+deploy`). Combine related scopes with `+` when a change spans a couple of areas (e.g. `auth+security`, `vouchers+billing`).
- **summary**: imperative mood, lowercase start, no trailing period.
- Add a blank line then a body when the change needs context (what/why), wrapped at ~72 chars.
- Keep each commit focused: split unrelated changes into separate, meaningful commits rather than one catch-all commit.

Examples:
- `refactor(billing): unify billing_category resolution`
- `feat(vouchers): admin list / get endpoints`
- `fix(vouchers+billing): voucher_grant rounding`
- `chore(infra+deploy): rotate voucher secret`

## Pull request descriptions

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
