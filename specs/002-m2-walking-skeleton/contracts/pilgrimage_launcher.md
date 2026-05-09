# Contract: Pilgrimage Launcher (`bin/pilgrimage`)

**Invocation**: `./bin/pilgrimage` (from repo root) or `bin/pilgrimage`.

POSIX shell launcher (Constitution Principle II documented exception,
see plan.md Complexity Tracking).

## Behavior

1. Locates the `regina` interpreter via `command -v regina`. If not
   found: prints to stderr `pilgrimage: regina not found in PATH; install via 'brew install regina-rexx' (macOS) or 'sudo apt-get install -y regina-rexx' (Ubuntu)` and exits 127.
2. Resolves the repository root: the directory containing this
   launcher's parent. (The launcher MUST work whether invoked as
   `./bin/pilgrimage` from repo root or as an absolute path from any
   working directory.)
3. `cd`s into the repository root.
4. Sets `LC_ALL=C` (Decision 4, research.md — defends against locale
   divergence in Regina output).
5. `exec`s `regina lib/pilgrimage.rexx "$@"` — passing through any
   trailing arguments (M2 ignores them but the pass-through preserves
   future flexibility).

## Constraints

- MUST be POSIX-compatible shell (no Bash-isms beyond `command -v`).
  Target: `/bin/sh`.
- MUST be the entire bootstrap: no logic, no side effects beyond
  locating `regina` and `cd`-ing into the repo root.
- MUST NOT print any banner or wrapper text — all human-facing output
  is the runner's responsibility.
- MUST `exec` the runner (replace the launcher process) so the runner's
  exit code is the launcher's exit code.
- Set executable bit (`chmod +x`).

## Reference implementation

```sh
#!/bin/sh
# bin/pilgrimage — locate regina and run the pilgrimage runner.
# See specs/002-m2-walking-skeleton/contracts/pilgrimage_launcher.md.
set -eu

if ! command -v regina >/dev/null 2>&1; then
    printf 'pilgrimage: regina not found in PATH; install via "brew install regina-rexx" (macOS) or "sudo apt-get install -y regina-rexx" (Ubuntu)\n' >&2
    exit 127
fi

# Repo root is the parent of bin/.
launcher_dir=$(cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(cd -- "$launcher_dir/.." && pwd)
cd "$repo_root"

LC_ALL=C exec regina lib/pilgrimage.rexx "$@"
```
