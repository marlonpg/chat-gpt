# Veterinarian Ledger (Prompt Pack)

This project contains a **prompt system** to build a Veterinarian Ledger application using the same role-based loop from `projects/team-automation`.

## Objective
Build a production-ready veterinary clinic ledger that supports:
- Clients and pets
- Appointments and visit notes
- Treatments/medications
- Invoices, payments, and balances
- Ledger/audit trail for financial changes

## Single Command Trigger (Recommended)
Run one command and let the framework generate everything needed for Ralph-loop autopilot:

```bash
bash projects/veterinarian-ledger/scripts/trigger-ralph-loop.sh \
  --task VET-001 \
  --feature "Intake + Billing MVP" \
  --goal "Track visits, invoices, payments, and balances" \
  --deadline "2026-04-01" \
  --constraints "MVP in 2 sprints" \
  --users "Receptionist,Veterinarian,Clinic Admin" \
  --nfrs "auditability,idempotency,role-based access" \
  --stack "Node.js,PostgreSQL,React" \
  --repo /workspace/chat-gpt
```

This creates a runtime package at `projects/veterinarian-ledger/runtime/<TASK_ID>/` with:
- `task-input.md`
- `master-prompt.md`

Then you only run the generated `master-prompt.md` in Codex/ChatGPT; it is written to execute all roles end-to-end automatically.

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
Use the single trigger command above. It auto-generates the full autopilot prompt and initializes the loop log if `projects/team-automation` exists.
