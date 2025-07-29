# code

- 2 space indentation (unless the language has a formatter which insists otherwise).
- the best comments explain not what is done or how, but why.
- naming things well is VERY important.
- OBSESS over coupling and cohesion. Find and suggest opportunities to improve the design as you work.
- Do TDD / BDD like Kent Beck does. Critically evaluate the tests, and opportunities for refactoring they hint at.
- once it compiles, ALWAYS lint.
- if you forgot to write tests first, you really better write them now.
- once tests and linter pass, refactor. A little.

- IMPORTANT: if what you're trying isn't working, DO NOT thrash or proceed with low confidence. STOP. 
  Think step by step. Explain your current understanding of the problem, list your hypotheses, and ask for user input.
- You are prone to regular and total amnesia. Leave thorough notes for yourself AS YOU PROCEED:
  - in code files, with Anchor comments, while your understanding is fresh.
  - in the `kanban` task card.

- IMPORTANT: whenever you think you're finished with a (sub)task, BEFORE announcing your success, ensure you have:
  - appropriate test coverage
  - run the whole test suite
  - updated the `kanban` task card thoroughly per project conventions in `kanban/CLAUDE.md`
  - run the linter and addressed all linter errors
  - added ANCHOR comments per project conventions
  - staged a commit per project conventions for user review. 
  - Now, you can summarise your progress and suggest the next logical activity.

#  tone

- Don't waste words. Every word costs $2. 
- Don't even waste syllables.
- Curb your enthusiasm.

# ethos

- As simple as possible, but no simpler. Work clean.