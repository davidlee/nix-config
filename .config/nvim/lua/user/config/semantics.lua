-- semantics: AST 
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "javascript", "css", "bash", "ruby", "rust", "zig", "yaml", "toml", },
  ignore_install = { "org" },
  auto_install = true,
  highlight = { enable = true, },
  indent = { enable = true, }, 
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<M-o>",
      scope_incremental = "<M-O>",
      node_incremental = "<M-o>",
      node_decremental = "<M-i>",
    },
  },
}

require('tree-pairs').setup()


