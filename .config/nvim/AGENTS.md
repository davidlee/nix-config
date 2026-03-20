# Neovim Config (nightly)

NixOS-based neovim nightly configuration. Plugins installed via `vim.pack` (native pack interface). See also: `~/flakes/modules/home/nvim.nix` for nix-level config.

## Structure

```
init.lua              → sets leader keys, requires boot.lua
lua/
  boot.lua            → load order: options → packfile → plugins → commands → keymap
  packfile.lua        → plugin installation manifest (vim.pack.add)
  config/
    options.lua       → vim options, theme (gruvbox), abbreviations
    keymap.lua        → centralised keybindings, exports Keys table
  plugins/
    init.lua          → lazy-load registry using `lze` (lz.load)
    lsp.lua           → LSP servers (built-in vim.lsp, not lazy-loaded)
    completion.lua    → blink.cmp + lazydev
    treesitter.lua    → treesitter + text objects
    ui.lua            → mini.icons/git/diff/statusline/surround, which-key,
                        gitsigns, bufferline, notify, noice, navic,
                        smart-splits, smear-cursor, edgy
    snacks.lua        → primary picker, terminal, explorer, scratch, zen, etc.
    editor.lua        → mini.surround, yanky, todo-comments, auto-save
    format.lua        → conform.nvim (stylua, shfmt, alejandra, goimports, etc.)
    lint.lua          → nvim-lint (selene, clippy, eslint, ruff, etc.)
    highlight.lua     → vim-illuminate
    movement.lua      → flash.nvim, aerial.nvim, fzf-lua
    modes.lua         → render-markdown, zk, outline, ts-autotag, d2, kanban, slim
    file_managers.lua → yazi, triptych, lsp-file-operations
    trouble.lua       → diagnostics panel
    amenities.lua     → startuptime, vim-sleuth
    autopairs.lua     → nvim-autopairs (treesitter-aware)
    checkmate.lua     → markdown checklists
    snippets.lua      → LuaSnip + friendly-snippets
    zk.lua            → zettelkasten (zk CLI)
    render-markdown.lua → markdown rendering (obsidian preset)
    disabled/         → parked plugin configs (neorg, project)
  local/
    commands/
      init.lua        → loads obsidian + redir commands
      obsidian.lua    → :Daily, :Weekly, :Monthly (env-var driven paths)
      redir.lua       → :Redir — capture command output in buffer
    packages/
      os.lua          → is_mac() / is_linux()
      shell.lua       → sh_word() — run shell, return trimmed output
```

## Conventions

- **Plugin management**: `vim.pack.add()` in packfile.lua for installation; `lze` / `lz.load()` in plugins/ for lazy config.
- **Keymaps**: centralised in `config/keymap.lua`. Plugins reference `Keys.<group>` rather than defining their own.
- **Leader groups**: `<space>` leader, `\` localleader. Groups: f=File, b=Buffer, g=Git, s=Search, r=Surround, x=Trouble, u=Toggle, y=Clipboard.
- **LSP**: uses built-in `vim.lsp.enable()` directly — not lazy-loaded, not via lspconfig wrappers.
- **One file per concern** in plugins/. Each returns a table for `lz.load()`.
- **Formatting**: stylua (2-space indent, 120 col, collapse simple statements). Config in `stylua.toml`.
- **Linting**: selene with neovim std. Config in `selene.toml`.
- **Theme**: gruvbox (set in options.lua).

## Tooling

- `just update` — headless plugin update via `vim.pack.update()`
- `stylua` — lua formatter
- `selene` — lua linter (std=neovim)
- `shell.nix` — nix dev shell
- `neovim.yml` — lua51 base, vim global

## Key design choices

- Snacks.nvim is the primary UI hub (picker, terminal, explorer, notifications, scratch, zen).
- Multiple file managers coexist: snacks explorer (primary), yazi, triptych.
- Format-on-save via conform.nvim with LSP fallback.
- Lint-on-save via nvim-lint.
- Cross-platform (NixOS + macOS) via `local/packages/os.lua`.
- Obsidian vault integration via custom commands using env vars (`OBS_VAULT_PATH`, `OBS_VAULT`, date format vars).
