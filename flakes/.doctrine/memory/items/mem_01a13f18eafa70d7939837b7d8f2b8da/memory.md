Worked for SL-004's design review (RV-009, four rounds):

- Launch: `node ~/.claude/plugins/cache/openai-codex/codex/<ver>/scripts/codex-companion.mjs task --background --effort high "<prompt>"`.
  Default model comes from `~/.codex/config.toml` (gpt-6.1-sol at the time).
  `adversarial-review` reviews diffs, not design docs; use `task` for designs.
- Wait: poll `status <job-id> --json` until status is completed/failed in a
  background Bash loop; fetch with `result <job-id>`. Name the job id explicitly.
- Rounds 2+: `--resume-last` keeps Codex's context.
- Ledger writes fail: even with `--write`, `doctrine review ...` hits
  "Read-only file system (os error 30)" on the RV lock in Codex's sandbox. Ask
  Codex for a fixed output shape (VERIFY/CONTEST/RAISE/CONCLUDE lines) and
  record its acts as raiser yourself, noting the attribution in each note.
- Codex could not reach the Lix daemon socket, so full `just drvs` identity is
  not something it can verify; it does pure evals well.
- Prompt it to verify every claim against code and upstream store sources;
  that is where its findings came from (it caught 1 blocker, 3 majors).
