return {

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add grammars
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "zig",
        "elixir",
        "ruby",
        "css",
      })
      -- vim.fn.remove(l, )
    end,
  },
}
