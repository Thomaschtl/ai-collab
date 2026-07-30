#!/usr/bin/env bash
# fetch_task.sh — Pull ai-collab and copy TASK.md + STATE.md locally.
# Clone this repo somewhere and run this script before starting a Codex task.
#
# Usage: scripts/fetch_task.sh [target_dir]
#   target_dir: where to copy TASK.md and STATE.md (default: current dir)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLLAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="${1:-$COLLAB_DIR}"

# Pull latest
git -C "$COLLAB_DIR" pull --quiet

TASK_ID=$(grep -E "^Task ID:" "$COLLAB_DIR/TASK.md" | head -1 | sed 's/Task ID: *//' || true)

if [[ -z "$TASK_ID" || "$TASK_ID" == "(none)" ]]; then
  echo "No task available in TASK.md."
  exit 0
fi

echo "Current task: $TASK_ID"
echo "Read: $COLLAB_DIR/TASK.md"
echo "Read: $COLLAB_DIR/STATE.md"
