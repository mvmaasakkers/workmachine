#!/usr/bin/env python3
"""Check the pinned tool versions in vars.yml against their upstream sources.

Reports what could be upgraded and, with --write, rewrites vars.yml in place
(including the Terraform and Packer SHA256 checksums, which have to move along
with their version).

Only the stdlib is used, so this runs on a bare runner without a pip install.

  ./scripts/bump-versions.py            # report only
  ./scripts/bump-versions.py --write    # apply the new versions to vars.yml

Versions that are pinned on purpose to a major (or major.minor) are not checked:
nodejs, php, composer and python track a distro/repo series rather than the
latest upstream release, so bumping them is a deliberate decision.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
VARS_FILE = REPO_ROOT / "vars.yml"

USER_AGENT = "workmachine-version-check"
TIMEOUT = 30

# Semantic-ish tags: 1.2.3, v1.2.3, 0.7.1. Excludes rc/beta/nightly/stable tags.
SEMVER_TAG = r"^v?\d+(\.\d+)*$"

CHECKS = [
    {"var": "lazygit_version", "kind": "github", "repo": "jesseduffield/lazygit"},
    {"var": "neovim_version", "kind": "github", "repo": "neovim/neovim"},
    {"var": "netbird_version", "kind": "github", "repo": "netbirdio/netbird"},
    {"var": "go_version", "kind": "go"},
    {"var": "rust_version", "kind": "rust"},
    {"var": "nvm_version", "kind": "github", "repo": "nvm-sh/nvm"},
    {"var": "codex_version", "kind": "npm", "package": "@openai/codex"},
    {"var": "herdr_version", "kind": "github", "repo": "ogulcancelik/herdr"},
    # Marksman tags are dates (2026-02-08), not semver.
    {"var": "marksman_version", "kind": "github", "repo": "artempyanykh/marksman",
     "pattern": r"^\d{4}-\d{2}-\d{2}$"},
    {"var": "eza_version", "kind": "github", "repo": "eza-community/eza"},
    {"var": "zsh_autosuggestions_version", "kind": "github", "repo": "zsh-users/zsh-autosuggestions"},
    {"var": "zsh_syntax_highlighting_version", "kind": "github", "repo": "zsh-users/zsh-syntax-highlighting"},
    {"var": "gh_version", "kind": "github", "repo": "cli/cli"},
    {"var": "terraform_version", "kind": "hashicorp", "product": "terraform",
     "checksums_var": "terraform_checksums"},
    {"var": "packer_version", "kind": "hashicorp", "product": "packer",
     "checksums_var": "packer_checksums"},
]

# Checksum keys in vars.yml -> file name suffix in the HashiCorp SHA256SUMS file.
HASHICORP_TARGETS = {
    "linux_amd64": "linux_amd64.zip",
    "linux_arm64": "linux_arm64.zip",
}


class CheckError(Exception):
    """An upstream source could not be resolved."""


# ---------------------------------------------------------------- http helpers


def fetch(url: str, headers: dict[str, str] | None = None) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, **(headers or {})})
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            return response.read()
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError) as exc:
        raise CheckError(f"{url}: {exc}") from exc


def fetch_json(url: str, headers: dict[str, str] | None = None):
    try:
        return json.loads(fetch(url, headers))
    except json.JSONDecodeError as exc:
        raise CheckError(f"{url}: invalid JSON ({exc})") from exc


# ------------------------------------------------------------ version ordering


def version_key(value: str) -> tuple:
    """Sort key that compares numeric runs numerically, text lexically."""
    parts = re.findall(r"\d+|[A-Za-z]+", value)
    return tuple((0, int(part)) if part.isdigit() else (1, part) for part in parts)


def is_newer(candidate: str, current: str) -> bool:
    return version_key(candidate) > version_key(current)


# ------------------------------------------------------------------- resolvers


def github_latest(repo: str, pattern: str = SEMVER_TAG) -> str:
    """Highest matching non-prerelease tag.

    `releases/latest` is not used: several projects (neovim for one) also publish
    rolling `stable`/`nightly` releases, which would resolve to a tag that is not
    a version.
    """
    headers = {"Accept": "application/vnd.github+json"}
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"

    releases = fetch_json(f"https://api.github.com/repos/{repo}/releases?per_page=50", headers)
    tags = [
        release["tag_name"]
        for release in releases
        if not release.get("draft") and not release.get("prerelease")
        and re.match(pattern, release.get("tag_name", ""))
    ]
    if not tags:
        raise CheckError(f"{repo}: no release tag matching {pattern}")
    return max(tags, key=version_key).lstrip("v")


def go_latest() -> str:
    releases = fetch_json("https://go.dev/dl/?mode=json")
    for release in releases:
        if release.get("stable") and release.get("version", "").startswith("go"):
            return release["version"][2:]
    raise CheckError("go.dev: no stable release found")


def rust_latest() -> str:
    channel = fetch("https://static.rust-lang.org/dist/channel-rust-stable.toml").decode()
    match = re.search(r'^version\s*=\s*"(\d+\.\d+\.\d+)', channel, re.MULTILINE)
    if not match:
        raise CheckError("static.rust-lang.org: no version in stable channel")
    return match.group(1)


def npm_latest(package: str) -> str:
    return fetch_json(f"https://registry.npmjs.org/{package}/latest")["version"]


def hashicorp_latest(product: str) -> str:
    index = fetch_json(f"https://releases.hashicorp.com/{product}/index.json")
    stable = [
        version for version in index.get("versions", {})
        if re.match(r"^\d+(\.\d+)*$", version)
    ]
    if not stable:
        raise CheckError(f"{product}: no stable version in release index")
    return max(stable, key=version_key)


def hashicorp_checksums(product: str, version: str) -> dict[str, str]:
    url = f"https://releases.hashicorp.com/{product}/{version}/{product}_{version}_SHA256SUMS"
    sums = fetch(url).decode()
    found = {}
    for line in sums.splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue
        checksum, filename = parts
        for key, suffix in HASHICORP_TARGETS.items():
            if filename == f"{product}_{version}_{suffix}":
                found[key] = checksum
    missing = set(HASHICORP_TARGETS) - set(found)
    if missing:
        raise CheckError(f"{product} {version}: no checksum for {', '.join(sorted(missing))}")
    return found


def resolve(check: dict) -> str:
    kind = check["kind"]
    if kind == "github":
        return github_latest(check["repo"], check.get("pattern", SEMVER_TAG))
    if kind == "go":
        return go_latest()
    if kind == "rust":
        return rust_latest()
    if kind == "npm":
        return npm_latest(check["package"])
    if kind == "hashicorp":
        return hashicorp_latest(check["product"])
    raise CheckError(f"unknown check kind {kind}")


def source_label(check: dict) -> str:
    return {
        "github": lambda: check["repo"],
        "go": lambda: "go.dev/dl",
        "rust": lambda: "static.rust-lang.org",
        "npm": lambda: check.get("package", ""),
        "hashicorp": lambda: f"releases.hashicorp.com/{check.get('product', '')}",
    }[check["kind"]]()


# --------------------------------------------------------------- vars.yml edit


def read_scalar(text: str, var: str) -> str | None:
    match = re.search(rf'^{re.escape(var)}:\s*"([^"]*)"', text, re.MULTILINE)
    return match.group(1) if match else None


def write_scalar(text: str, var: str, value: str) -> str:
    new_text, count = re.subn(
        rf'^({re.escape(var)}:\s*")[^"]*(")',
        rf"\g<1>{value}\g<2>",
        text,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise CheckError(f"could not rewrite {var} in {VARS_FILE.name}")
    return new_text


def write_checksums(text: str, var: str, checksums: dict[str, str]) -> str:
    """Rewrite the keys of a `<var>:` mapping block, leaving the rest alone."""
    lines = text.splitlines(keepends=True)
    start = next((i for i, line in enumerate(lines) if line.startswith(f"{var}:")), None)
    if start is None:
        raise CheckError(f"could not find {var} in {VARS_FILE.name}")

    written = set()
    for index in range(start + 1, len(lines)):
        line = lines[index]
        if line.strip() and not line.startswith((" ", "\t")):
            break  # end of the mapping block
        match = re.match(r'^(\s+)(\w+):\s*"([^"]*)"', line)
        if match and match.group(2) in checksums:
            indent, key, _ = match.groups()
            lines[index] = f'{indent}{key}: "{checksums[key]}"\n'
            written.add(key)

    missing = set(checksums) - written
    if missing:
        raise CheckError(f"{var}: no key(s) {', '.join(sorted(missing))} to rewrite")
    return "".join(lines)


# ---------------------------------------------------------------------- report


def markdown_report(updates: list[dict], failures: list[str]) -> str:
    lines = []
    if updates:
        lines += [
            "| Tool | Current | Latest | Source |",
            "| --- | --- | --- | --- |",
        ]
        for update in updates:
            lines.append(
                f"| `{update['var']}` | {update['current']} | **{update['latest']}** | {update['source']} |"
            )
    else:
        lines.append("All pinned versions are up to date.")
    if failures:
        lines += ["", "### Could not be checked", ""]
        lines += [f"- {failure}" for failure in failures]
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--write", action="store_true", help="apply the new versions to vars.yml")
    parser.add_argument("--report", metavar="FILE", help="write a markdown report to FILE")
    args = parser.parse_args()

    text = VARS_FILE.read_text()
    updates: list[dict] = []
    failures: list[str] = []

    for check in CHECKS:
        var = check["var"]
        current = read_scalar(text, var)
        if current is None:
            failures.append(f"`{var}` not found in {VARS_FILE.name}")
            continue
        try:
            latest = resolve(check)
        except CheckError as exc:
            failures.append(f"`{var}`: {exc}")
            continue

        if not is_newer(latest, current):
            print(f"  ok      {var:<34} {current}")
            continue

        update = {
            "var": var,
            "current": current,
            "latest": latest,
            "source": source_label(check),
            "checksums_var": check.get("checksums_var"),
            "product": check.get("product"),
        }
        if update["checksums_var"]:
            try:
                update["checksums"] = hashicorp_checksums(check["product"], latest)
            except CheckError as exc:
                failures.append(f"`{var}`: {exc}")
                continue
        updates.append(update)
        print(f"  update  {var:<34} {current} -> {latest}")

    for failure in failures:
        print(f"  FAILED  {failure}", file=sys.stderr)

    if args.write and updates:
        for update in updates:
            text = write_scalar(text, update["var"], update["latest"])
            if update["checksums_var"]:
                text = write_checksums(text, update["checksums_var"], update["checksums"])
        VARS_FILE.write_text(text)
        print(f"\nwrote {len(updates)} update(s) to {VARS_FILE}")

    if args.report:
        Path(args.report).write_text(markdown_report(updates, failures))

    print(f"\nupdates available: {len(updates)}")
    return 2 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
