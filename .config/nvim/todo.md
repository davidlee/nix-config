## neovim config todo

### Refactor

- [x] flatten modes.lua: move render-markdown, zk, checkmate requires into plugins/init.lua
  - these standalone files are require()'d from modes.lua instead of init.lua, breaking the convention
- [x] rename remaining modes.lua → languages.lua (ts-autotag, d2, slim, kanban, outline)
- [ ] decide: treesitter is commented out in plugins/init.lua:6 — re-enable or remove
- [ ] decide: checkmate is commented out in modes.lua:4 but file exists — enable or delete

### Cleanup

- [ ] remove stale `-- local md = require("mini.deps")` in render-markdown.lua and zk.lua
- [ ] remove stale `-- autopairs` comment in zk.lua:7
- [ ] nfrs.md is an empty kanban board — delete if vestigial
- [ ] README.md has two bare commands with no context — flesh out or delete

### LSP / etc
- [ ] luals 
- [ ] LSP / formatter for React / TypeScript / etc
- [ ] magic closing tags for HTML / TSX

### other
- [x] set up or fix: move line up / down @done(06/21/25 13:58)
  - it's Alt-[j/k] not Ctrl-[j/k]
- [ ] ! learn / config: fancy editing of surrounding braces etc
  - mini-surround in keymap.lua:109
  - [ ] TODO: try it out with a working LSP
