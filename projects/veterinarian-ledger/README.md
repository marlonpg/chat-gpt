# Veterinarian Ledger (Prompt Pack)

This project contains a **prompt system** to build a Veterinarian Ledger application using the same role-based loop from `projects/team-automation`.

## Objective
Build a production-ready veterinary clinic ledger that supports:
- Clients and pets
- Appointments and visit notes
- Treatments/medications
- Invoices, payments, and balances
- Ledger/audit trail for financial changes

## Suggested Delivery Flow (Ralph Loop)
1. Run `prompts/00-orchestrator-kickoff.md`
2. Run `prompts/01-product-owner.md`
3. Run `prompts/02-architect.md`
4. Run `prompts/03-ux-designer.md`
5. Run `prompts/04-backend-developer.md`
6. Run `prompts/05-frontend-developer.md`
7. Run `prompts/06-orchestrator-validation.md`

## How to Use
1. Open a fresh task in your repository.
2. Copy one prompt file at a time into Codex/ChatGPT.
3. Paste outputs into your repo artifacts (`docs/`, issue comments, or PR notes).
4. Enforce handoff between roles before moving to the next prompt.

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
Use this when you want an orchestrator kickoff for feature `VET-001`:

```text
Use projects/veterinarian-ledger/prompts/00-orchestrator-kickoff.md with:
- TASK_ID: VET-001
- FEATURE: Intake + Billing MVP
- REPO_PATH: /workspace/chat-gpt
```
