#!/usr/bin/env bash
set -euo pipefail

TASK_ID=""
FROM=""
TO=""
SUMMARY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="$2"; shift 2 ;;
    --from) FROM="$2"; shift 2 ;;
    --to) TO="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$FROM" || -z "$TO" || -z "$SUMMARY" ]]; then
  echo "Usage: $0 --task <TASK-ID> --from <ROLE> --to <ROLE> --summary <TEXT>"
  exit 1
fi

LOG_DIR="$(dirname "$0")/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/${TASK_ID}.log"

echo "[$(date -Is)] HANDOFF $FROM -> $TO | $SUMMARY" >> "$LOG_FILE"
echo "Handoff logged to $LOG_FILE"
