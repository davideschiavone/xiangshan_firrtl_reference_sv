#!/usr/bin/env bash
#
# scripts/regenerate.sh — populate this repo from a freshly-regenerated bianco checkout.
#
# Usage:
#   bash scripts/regenerate.sh <BIANCO_PATH>
#
# The given <BIANCO_PATH> must be a clone of github.com/davideschiavone/bianco
# where you've already run:
#   bash setup.sh
#   source ~/.bianco_env
#   make reference   # firtool emit
#   make wrappers    # wrappergen pass
#
# Then this script:
#   1. rsyncs reference_sv/, build/wrappers/, docs/sibling_groups.json from bianco
#   2. Removes any files in this repo that the bianco source no longer emits
#   3. Records the bianco HEAD SHA in .bianco-source-sha for audit
#
# You then `git add -A && git commit && git push` from THIS repo's root.

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <BIANCO_PATH>" >&2
    exit 1
fi

BIANCO_PATH="$(realpath "$1")"
THIS_REPO="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d "${BIANCO_PATH}/.git" ]]; then
    echo "ERROR: ${BIANCO_PATH} is not a git repo" >&2
    exit 1
fi
if [[ ! -d "${BIANCO_PATH}/reference_sv" ]] \
        || ! ls "${BIANCO_PATH}/reference_sv"/*.sv >/dev/null 2>&1; then
    echo "ERROR: ${BIANCO_PATH}/reference_sv/ is empty." >&2
    echo "       Did you run 'make reference' in that bianco checkout?" >&2
    exit 1
fi
if [[ ! -d "${BIANCO_PATH}/build/wrappers" ]] \
        || ! ls "${BIANCO_PATH}/build/wrappers"/*_wrapper.sv >/dev/null 2>&1; then
    echo "ERROR: ${BIANCO_PATH}/build/wrappers/ is empty." >&2
    echo "       Did you run 'make wrappers' in that bianco checkout?" >&2
    exit 1
fi
if [[ ! -f "${BIANCO_PATH}/docs/sibling_groups.json" ]]; then
    echo "ERROR: ${BIANCO_PATH}/docs/sibling_groups.json missing." >&2
    echo "       Run 'make sibling-groups' in that bianco checkout." >&2
    exit 1
fi

echo "==> Source: ${BIANCO_PATH}"
echo "==> Target: ${THIS_REPO}"
echo

# rsync --delete keeps the target in lockstep with the source — any
# files that bianco no longer emits get removed here.
mkdir -p "${THIS_REPO}/reference_sv" \
         "${THIS_REPO}/build/wrappers" \
         "${THIS_REPO}/docs"

echo "==> Syncing reference_sv/ ($(find "${BIANCO_PATH}/reference_sv" -type f | wc -l) files)"
rsync -a --delete \
    --exclude='.gitkeep' \
    "${BIANCO_PATH}/reference_sv/" \
    "${THIS_REPO}/reference_sv/"

echo "==> Syncing build/wrappers/ ($(find "${BIANCO_PATH}/build/wrappers" -type f | wc -l) files)"
rsync -a --delete \
    "${BIANCO_PATH}/build/wrappers/" \
    "${THIS_REPO}/build/wrappers/"

echo "==> Syncing docs/sibling_groups.json"
cp "${BIANCO_PATH}/docs/sibling_groups.json" "${THIS_REPO}/docs/sibling_groups.json"

# Record the bianco HEAD SHA so consumers can pin the regenerated content
# to a specific bianco commit.
BIANCO_SHA="$(git -C "${BIANCO_PATH}" rev-parse HEAD)"
BIANCO_BRANCH="$(git -C "${BIANCO_PATH}" rev-parse --abbrev-ref HEAD)"
XS_SHA="$(git -C "${BIANCO_PATH}/XiangShan" rev-parse HEAD 2>/dev/null || echo unknown)"
cat > "${THIS_REPO}/.bianco-source-sha" <<EOF
bianco-sha: ${BIANCO_SHA}
bianco-branch: ${BIANCO_BRANCH}
xiangshan-submodule-sha: ${XS_SHA}
regenerated-at: $(date --iso-8601=seconds)
EOF

echo
echo "==> Done. Next steps:"
echo "    cd ${THIS_REPO}"
echo "    git status                  # inspect changes"
echo "    git add -A"
echo "    git commit -m 'regenerate artifacts at bianco ${BIANCO_SHA:0:12}'"
echo "    git push"
