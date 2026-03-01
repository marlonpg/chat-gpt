# Skill: Git Operations

## Purpose
Ensure each role delivers changes with clean and auditable git operations.

## Standard Steps
1. `git pull --rebase`
2. Implement scoped changes.
3. Run checks/tests.
4. `git add -A`
5. `git commit -m "<type>(<scope>): <summary>"`
6. `git push`

## Commit Rules
- Small, logically grouped commits.
- Message must describe intent and outcome.
- Include affected area/scope.

## Push Rules
- Push only when checks succeed.
- If blocked, report blocker with remediation plan.
