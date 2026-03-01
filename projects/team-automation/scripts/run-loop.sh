#!/usr/bin/env bash
set -euo pipefail

TASK_ID=""
TITLE=""
REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$TITLE" || -z "$REPO" ]]; then
  echo "Usage: $0 --task <TASK-ID> --title <TITLE> --repo <REPO_PATH>"
  exit 1
fi

LOG_DIR="$(dirname "$0")/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/${TASK_ID}.log"

{
  echo "[$(date -Is)] START task=$TASK_ID title=$TITLE repo=$REPO"
  echo "[$(date -Is)] Stage: Intake -> Product Owner"
  echo "[$(date -Is)] Stage: Product Owner -> Architect"
  echo "[$(date -Is)] Stage: Architect -> UX/Developers"
  echo "[$(date -Is)] Stage: Implementation in progress"
  echo "[$(date -Is)] NOTE: Ensure each delivery role commits and pushes changes"
} >> "$LOG_FILE"

echo "Ralph loop initialized. Log: $LOG_FILE"
