---
name: commit-message
description: Formats git commit subjects as Conventional Commits with a lowercase scope, prefixing the Jira ticket ID from the current branch name when one is present. Use this skill whenever drafting a commit message, running `git commit`, or when asked to write/fix a commit subject or body.
---

# Commit Messages

Write commit subjects as Conventional Commits with a scope. If the current
branch name contains a Jira ticket ID, prefix the subject with that ID:

```
<type>(<scope>): <short imperative summary>
```

```
<JIRA-ID> <type>(<scope>): <short imperative summary>
```

- **type**: one of `feat`, `fix`, `refactor`, `chore`, `docs`, `deploy`, `test`, `perf`, `style`, `build`, `ci`.
- **scope**: the area touched, in parentheses, lowercase (e.g. `billing`, `vouchers`, `auth`, `i18n`, `infra+deploy`). Combine related scopes with `+` when a change spans a couple of areas (e.g. `auth+security`, `vouchers+billing`).
- **summary**: imperative mood, lowercase start, no trailing period.
- **JIRA-ID**: only include when present in the current branch name (e.g. `ABC-123` from `feature/ABC-123-add-login`). Preserve uppercase.
- Add a blank line then a body when the change needs context (what/why), wrapped at ~72 chars.
- Keep each commit focused: split unrelated changes into separate, meaningful commits rather than one catch-all commit.

Examples:
- `refactor(billing): unify billing_category resolution`
- `ABC-123 refactor(billing): unify billing_category resolution`
- `feat(vouchers): admin list / get endpoints`
- `fix(vouchers+billing): voucher_grant rounding`
- `chore(infra+deploy): rotate voucher secret`
