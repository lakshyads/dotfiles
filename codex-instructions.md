# Git Conventions

## Commit Messages

Write commit subjects as Conventional Commits with a scope. If the current
branch name contains a Jira ticket ID, prefix the subject with that ID:

```
<type>(<scope>): <short imperative summary>
```

```
<JIRA-ID> <type>(<scope>): <short imperative summary>
```

- **type**: one of `feat`, `fix`, `refactor`, `chore`, `docs`, `deploy`, `test`, `perf`, `style`, `build`, `ci`.
- **scope**: area touched, lowercase (e.g. `billing`, `auth`). Combine related scopes with `+` (e.g. `auth+security`, `vouchers+billing`).
- **summary**: imperative mood, lowercase start, no trailing period.
- **JIRA-ID**: only include when present in the current branch name (e.g. `ABC-123` from `feature/ABC-123-add-login`). Preserve uppercase.
- Add a blank line then a body for context (what/why), wrapped at ~72 chars.
- Keep each commit focused — split unrelated changes into separate commits.

Examples:
- `refactor(billing): unify billing_category resolution`
- `ABC-123 refactor(billing): unify billing_category resolution`
- `feat(vouchers): admin list / get endpoints`
- `fix(vouchers+billing): voucher_grant rounding`
- `chore(infra+deploy): rotate voucher secret`

## Pull Requests

- **Title**: under 70 characters, concise, imperative mood.
- **Body**:

  ```
  ## Summary
  <1-3 bullet points>

  ## Test plan
  [Bulleted markdown checklist of TODOs for testing the PR]
  ```
