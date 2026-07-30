#!/usr/bin/env bash
# publish_report.sh — Commit and push REPORT.md + STATE.md to ai-collab.
# Run this from inside a local clone of ai-collab after Codex has written the report.
#
# Usage: scripts/publish_report.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLLAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORT_MD="$COLLAB_DIR/REPORT.md"
STATE_MD="$COLLAB_DIR/STATE.md"

for f in "$REPORT_MD" "$STATE_MD"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Missing $f" >&2; exit 1
  fi
done

TASK_ID=$(grep -E "^Task ID:" "$REPORT_MD" | head -1 | sed 's/Task ID: *//' || echo "unknown")
STATUS=$(grep -E "^Status:" "$REPORT_MD" | head -1 | sed 's/Status: *//' || echo "unknown")

# Archive previous report if different task
PREV=$(grep -E "^Task ID:" "$COLLAB_DIR/REPORT.md" 2>/dev/null | head -1 | sed 's/Task ID: *//' || true)
if [[ -n "$PREV" && "$PREV" != "$TASK_ID" && "$PREV" != "(none)" ]]; then
  TS=$(date -u +"%Y%m%dT%H%M%SZ")
  mkdir -p "$COLLAB_DIR/archive"
  cp "$COLLAB_DIR/REPORT.md" "$COLLAB_DIR/archive/REPORT_${PREV}_${TS}.md"
  git -C "$COLLAB_DIR" add "$COLLAB_DIR/archive/" 2>/dev/null || true
fi

git -C "$COLLAB_DIR" add REPORT.md STATE.md

if git -C "$COLLAB_DIR" diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

git -C "$COLLAB_DIR" commit -m "codex: report task $TASK_ID [$STATUS]"
git -C "$COLLAB_DIR" push origin main

HASH=$(git -C "$COLLAB_DIR" rev-parse --short HEAD)
echo "Published: $HASH"
echo "https://github.com/Thomaschtl/ai-collab/blob/main/REPORT.md"
