#!/usr/bin/env python3
"""Compare pinned tool versions in vars.yml against the latest stable releases.

Usage: python3 scripts/check-versions.py
Exit code 0 when everything is current, 1 when at least one pin is outdated.

Pin policies:
  - Exact pins (lazygit, go, terraform, ...) are compared against the latest
    stable release of the tool.
  - nodejs_version tracks the latest LTS major, not the "current" release line.
  - php_version and python_version are minor lines (e.g. "8.5"), compared
    against the newest stable minor line.
  - composer_version is a major line (e.g. "2").
When terraform, terraform-ls, or packer is outdated, the new linux
amd64/arm64 SHA256 checksums are printed ready to paste into vars.yml.

Set GITHUB_TOKEN to raise the GitHub API rate limit if needed.
"""

import json
import os
import re
import sys
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VARS_FILE = os.path.join(REPO_ROOT, "vars.yml")


def fetch(url):
    headers = {"User-Agent": "workmachine-version-check"}
    if "api.github.com" in url and os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = "Bearer " + os.environ["GITHUB_TOKEN"]
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=20) as resp:
        return resp.read().decode()


def fetch_json(url):
    return json.loads(fetch(url))


def github_latest(repo):
    tag = fetch_json(f"https://api.github.com/repos/{repo}/releases/latest")["tag_name"]
    return tag.lstrip("v")


def github_latest_stable_tag(repo):
    """Newest tag that looks like a plain stable version (for repos without releases)."""
    tags = [t["name"] for t in fetch_json(f"https://api.github.com/repos/{repo}/tags?per_page=100")]
    stable = [t.lstrip("v") for t in tags if re.fullmatch(r"v?\d+(\.\d+)+", t)]
    return max(stable, key=lambda v: [int(p) for p in v.split(".")])


def go_latest():
    return fetch_json("https://go.dev/dl/?mode=json")[0]["version"].lstrip("go")


def rust_latest():
    toml = fetch("https://static.rust-lang.org/dist/channel-rust-stable.toml")
    match = re.search(r'^\[pkg\.rust\]\nversion = "([\d.]+)', toml, re.M)
    return match.group(1)


def hashicorp_latest(product):
    return fetch_json(f"https://checkpoint-api.hashicorp.com/v1/check/{product}")["current_version"]


def hashicorp_checksums(product, version):
    sums = fetch(f"https://releases.hashicorp.com/{product}/{version}/{product}_{version}_SHA256SUMS")
    result = {}
    for line in sums.splitlines():
        for arch in ("amd64", "arm64"):
            if line.endswith(f"linux_{arch}.zip"):
                result[f"linux_{arch}"] = line.split()[0]
    return result


def npm_latest(package):
    return fetch_json(f"https://registry.npmjs.org/{package}/latest")["version"]


def node_latest_lts_major():
    releases = fetch_json("https://nodejs.org/dist/index.json")
    lts = next(r for r in releases if r["lts"])
    return lts["version"].lstrip("v").split(".")[0]


def php_latest_minor_line():
    latest = fetch_json("https://www.php.net/releases/?json")["8"]["version"]
    return ".".join(latest.split(".")[:2])


def python_latest_minor_line():
    return fetch_json("https://endoflife.date/api/python.json")[0]["cycle"]


def composer_latest_major():
    return github_latest("composer/composer").split(".")[0]


CHECKS = [
    # (vars.yml key, description of what "latest" means, resolver)
    ("lazygit_version", "latest release", lambda: github_latest("jesseduffield/lazygit")),
    ("neovim_version", "latest release", lambda: github_latest("neovim/neovim")),
    ("netbird_version", "latest release", lambda: github_latest("netbirdio/netbird")),
    ("go_version", "latest stable", go_latest),
    ("rust_version", "latest stable", rust_latest),
    ("nodejs_version", "latest LTS major", node_latest_lts_major),
    ("php_version", "latest stable minor line", php_latest_minor_line),
    ("composer_version", "latest major", composer_latest_major),
    ("python_version", "latest stable minor line", python_latest_minor_line),
    ("nvm_version", "latest release", lambda: github_latest("nvm-sh/nvm")),
    ("codex_version", "latest on npm", lambda: npm_latest("@openai/codex")),
    ("marksman_version", "latest release", lambda: github_latest("artempyanykh/marksman")),
    ("eza_version", "latest release", lambda: github_latest("eza-community/eza")),
    ("zsh_autosuggestions_version", "latest stable tag",
     lambda: github_latest_stable_tag("zsh-users/zsh-autosuggestions")),
    ("zsh_syntax_highlighting_version", "latest stable tag",
     lambda: github_latest_stable_tag("zsh-users/zsh-syntax-highlighting")),
    ("gh_version", "latest release", lambda: github_latest("cli/cli")),
    ("task_version", "latest release", lambda: github_latest("go-task/task")),
    ("caddy_version", "latest release", lambda: github_latest("caddyserver/caddy")),
    ("terraform_version", "latest stable", lambda: hashicorp_latest("terraform")),
    ("terraform_ls_version", "latest stable", lambda: hashicorp_latest("terraform-ls")),
    ("packer_version", "latest stable", lambda: hashicorp_latest("packer")),
]


def read_pinned_versions():
    pinned = {}
    with open(VARS_FILE) as f:
        for line in f:
            match = re.match(r'^(\w+_version(?:_short)?):\s*"([^"]+)"', line)
            if match:
                pinned[match.group(1)] = match.group(2)
    return pinned


def main():
    pinned = read_pinned_versions()
    outdated = []
    print(f"{'TOOL':<34} {'PINNED':<14} {'LATEST':<14} STATUS")
    for key, _policy, resolver in CHECKS:
        current = pinned.get(key)
        if current is None:
            print(f"{key:<34} {'-':<14} {'-':<14} not found in vars.yml")
            continue
        try:
            latest = resolver()
        except Exception as exc:
            print(f"{key:<34} {current:<14} {'?':<14} check failed: {exc}")
            continue
        status = "ok" if current == latest else "OUTDATED"
        if current != latest:
            outdated.append((key, current, latest))
        print(f"{key:<34} {current:<14} {latest:<14} {status}")

    for key, _current, latest in outdated:
        var_prefix = key.removesuffix("_version")
        product = var_prefix.replace("_", "-")
        if product in ("terraform", "terraform-ls", "packer"):
            try:
                sums = hashicorp_checksums(product, latest)
            except Exception as exc:
                print(f"\n{var_prefix}_checksums for {latest}: fetch failed: {exc}")
                continue
            print(f"\n{var_prefix}_version: \"{latest}\"")
            print(f"{var_prefix}_checksums:")
            for arch, digest in sorted(sums.items()):
                print(f"  {arch}: \"{digest}\"")

    if outdated:
        print(f"\n{len(outdated)} pin(s) outdated. Update vars.yml accordingly "
              "(php_version_short must match php_version).")
        return 1
    print("\nAll pins are up to date.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
