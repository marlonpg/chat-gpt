<<<<<<< ours
<<<<<<< ours
# Veterinarian Ledger (Prompt Pack)

This project contains a **prompt system** to build a Veterinarian Ledger application using the same role-based loop from `projects/team-automation`.

## Objective
Build a production-ready veterinary clinic ledger that supports:
- Clients and pets
- Appointments and visit notes
- Treatments/medications
- Invoices, payments, and balances
- Ledger/audit trail for financial changes

## True Ralph Loop (Repeated CLI Calls)
Yes, this is run from your **local terminal** in your repo.

### First command to run
```bash
bash projects/veterinarian-ledger/scripts/run-ralph-loop.sh \
  --task VET-001 \
  --repo /path/to/your/repo \
  --workdir projects/veterinarian-ledger
```

This script repeatedly calls your agent CLI each iteration (task-by-task), tracks progress in `progress.txt`, writes logs in `logs/`, retries on failures, and stops when all tasks are complete.

### Before running
1. Put your PRD at `projects/veterinarian-ledger/PRD.md`
2. Put tasks (one per line) at `projects/veterinarian-ledger/tasks.txt`
   - You can start from `projects/veterinarian-ledger/templates/tasks.txt`
3. Ensure your CLI command is available (default: `codex exec --skip-git-repo-check`)

### Agent command override (optional)
If you want to use another command:
```bash
bash projects/veterinarian-ledger/scripts/run-ralph-loop.sh \
  --task VET-001 \
  --repo /path/to/your/repo \
  --workdir projects/veterinarian-ledger \
  --agent-cmd "claude" \
  --agent-args "--print"
```

## Single Prompt Autopilot (Optional)
If you prefer one generated master prompt (manual paste/run), you can still use:

```bash
bash projects/veterinarian-ledger/scripts/trigger-ralph-loop.sh \
  --task VET-001 \
  --feature "Intake + Billing MVP" \
  --repo /path/to/your/repo
```

## Manual Prompt Flow (Optional)
1. Run `prompts/00-orchestrator-kickoff.md`
2. Run `prompts/01-product-owner.md`
3. Run `prompts/02-architect.md`
4. Run `prompts/03-ux-designer.md`
5. Run `prompts/04-backend-developer.md`
6. Run `prompts/05-frontend-developer.md`
7. Run `prompts/06-orchestrator-validation.md`

## Output Artifacts You Should Track
- `docs/requirements.md`
- `docs/architecture.md`
- `docs/ux-spec.md`
- `docs/api-contract.md`
- `docs/release-checklist.md`

## Git Discipline (for every implementation role)
- Pull latest branch state (`git pull --rebase`)
- Implement only assigned scope
- Run tests/checks
- Commit with meaningful message
- Push branch
- Provide PR-ready summary

## Starter Command Example
Use the true Ralph loop command above for iterative execution. Use `trigger-ralph-loop.sh` only if you want a one-shot generated prompt.
=======
=======
>>>>>>> theirs
# Veterinarian Ledger

This directory is the **product workspace** for the Veterinarian Ledger service.

## What belongs here
- Product requirements (`PRD.md`)
- Product task backlog (`tasks.txt`)
- Domain docs (`docs/`)
- Source code (`backend/`, `frontend/`, etc.)

## What does NOT belong here
Automation framework scripts, agents, and orchestration templates.
Those live in: `projects/team-automation/`.

## Run with Team Automation Ralph Loop
From repo root:

```bash
bash projects/team-automation/scripts/ralph-loop-runner.sh \
  --task VET-001 \
  --repo /path/to/your/repo \
  --project-dir projects/veterinarian-ledger
```

## Initial Files
- `PRD.md` (create/update for your product scope)
- `tasks.txt` (one task per line)
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
