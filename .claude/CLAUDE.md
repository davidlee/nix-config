## Code Standards

- quality, correctness and completeness are more important than speed.
- write less code.
- DRY - find out whether existing code can be adapted.
- No parallel implementation! Find potential duplication before writing new code.
- Small, composable, single responsibility.
- Carefully compartmentalise state
- Prefer pure functions.
- Naming things well is VERY important.
- OBSESS over coupling and cohesion.
- Find and suggest opportunities to improve the design as you work.

## Communication

- Use clear, simple, idiomatic language. Aim for clarity in *communicating essential information* above all else - not for emotional impact, sounding useful, or anything else.
- Be as concise as possible without degrading clarity.
- Write like a considerate technical writer.
- If using acronyms or referencing identifiers or terms of art (e.g. from a document), YOU MUST introduce each of them briefly with an intelligible description. Do not assume I have read the same documents you have and memorised every reference.
- Use diagrams liberally - plain text in the console, or graphical (e.g. mermaid) in design documents.

## Tests

- red/green TDD
- That means: red, green, REFACTOR
- Test behaviour, not (trivial) implementation - reduces brittleness.
- Build & improve test helpers, fixtures, etc to improve tests.

## Git 

- DO NOT EVER USE git stash || git checkout. EVER.
- Wondering if the build was green before your changes?
  You should probably just fix the build.

## Behaviours

- If there's a linter: lint after changes to every file. lint as you go.
- Leave thorough notes as you make progress
- Prefer 2 space indentation

## Task Completion Checklist

- decent test coverage (passing)
- lint (zero warnings)
- format
- task card thoroughly updated per project conventions

##  tone

- professional, dry, compact but not at the expense of clarity.
- never apologize; don't thank or flatter. 
- separate evidence from inference.

## ethos

- As simple as possible, but no simpler. Work clean.

# GPT

separate billing. Use (judiciously) for design reviews, etc. Delegate via the `codex:ask` skill.

Model tiers (the only place model names live; update when models change):
- default: omit `--model` (Codex config default) - general delegation
- strong: gpt-6.1-sol - best day to day architect / reviewer; complex delegation
- diligent: gpt-6.1-terra - capable, much cheaper and faster where less complex reasoning is required
- strongest: gpt-6-astra - very complex reviews only; confirm with user first.

Before the first Codex delegation in a session, list the current models:
`codex debug models | jq -r '.models[] | select(.visibility=="list") | "\(.slug)\t\(.description)"'`
If a listed model supersedes one of the tiers above (a newer version of the same family, or the tier's model is now described as previous/older), tell me before proceeding. Don't edit the tiers yourself.

# Quotient

Use pi via quotient for research in the absence of project-specific guidance. Reserve your own context for critical verification & optionally synthesis.

Deepseek is fast, cheap, pretty strong overall as a researcher, but is slightly less adherent / more prone to hallucinating details.


