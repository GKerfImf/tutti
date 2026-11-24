# Shared helpers for .agents/scripts. Source it; don't run it.
set -euo pipefail

# Repo root, so scripts work from any subdirectory.
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# elan's toolchain shims, in case the shell profile didn't add them.
export PATH="$HOME/.elan/bin:$PATH"

# Non-interactive SSH: fail fast instead of hanging on a prompt.
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o ConnectTimeout=15 -o BatchMode=yes}"

# owner/name of the GitHub repo, e.g. GKerfImf/tutti.
repo() { gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null; }

# gh, minus the "gh event listen" hint block it prints on stderr.
ghq() {
  gh "$@" 2> >(grep -vE '^(hint: |    gh event listen|  - )' >&2)
}

die() { echo "error: $*" >&2; exit 1; }
