#!/usr/bin/env bash
set -euo pipefail

TASK_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" ]]; then
  echo "Usage: $0 --task <TASK-ID>"
  exit 1
fi

LOG_FILE="$(dirname "$0")/../logs/${TASK_ID}.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "No log found for task $TASK_ID"
  exit 1
fi

echo "=== Status report for $TASK_ID ==="
cat "$LOG_FILE"
