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

- professional, dry, compact.
- hold caveman-mode when discussing architecture. Aim for
  comprensibility, not manufacturing a black hole out of words.

## ethos

- As simple as possible, but no simpler. Work clean.

# GPT

separate billing. Use (judiciously) for design reviews, etc.

gpt-5.6-sol (current) - Frontier. Best architect / reviewer.
