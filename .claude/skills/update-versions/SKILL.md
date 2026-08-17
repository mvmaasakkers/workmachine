---
name: update-versions
description: Check whether the tool versions pinned in vars.yml are still the latest stable releases and update the outdated ones, including HashiCorp checksums. Use when asked to check or bump tool versions in this repo.
---

# Update pinned tool versions

All tool versions for this Ansible workstation setup are pinned in `vars.yml`.

## Steps

1. Run `make check-versions` (wraps `scripts/check-versions.py`). It prints a
   table of every pin vs. the latest stable release and exits non-zero when
   something is outdated. For any outdated terraform/packer version it also
   prints the new `linux_amd64`/`linux_arm64` SHA256 checksums in a
   ready-to-paste block.
2. Update the outdated pins in `vars.yml`:
   - `php_version_short` must always match `php_version`.
   - `terraform_checksums` and `packer_checksums` must be updated together
     with their version — take the values the script printed.
3. Grep `README.md` and `docs/` for the old version strings — some versions
   (e.g. Rust) are hardcoded there too — and update any hits.
4. Re-run `make check-versions` and confirm everything reports `ok`.
5. Summarize which tools were bumped (old → new version).

## Pin policies

- Most pins are exact versions, compared against the latest stable release.
- `nodejs_version` tracks the latest **LTS** major, not the "current" line.
- `php_version` and `python_version` are minor lines (e.g. `8.5`), bumped only
  when a new stable minor line is released.
- `composer_version` is a major line (e.g. `2`).
- `marksman_version` is a date-formatted release tag, no `v` prefix.

## When a new tool gets pinned

If a new `*_version` variable is added to `vars.yml`, add a matching entry to
the `CHECKS` list in `scripts/check-versions.py` so it is covered next time.
The script has helpers for GitHub releases, GitHub tags, npm, go.dev, Rust,
and the HashiCorp checkpoint API.

## Troubleshooting

- GitHub API rate limiting (60 requests/hour unauthenticated): export
  `GITHUB_TOKEN` before running, the script picks it up automatically.
- If a single check fails (network, changed API), the script reports
  `check failed` for that row and continues; verify that tool manually via
  its release page.
