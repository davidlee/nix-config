require("plugins.treesitter")

require("lze").load({
  -- blink.cmp
  {
    "blink.cmp",
    after = function()
      require("blink.cmp").setup({
        sources = {
          -- add lazydev to your completion providers
          default = { "lazydev", "lsp", "path", "snippets", "buffer" },
          providers = {
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
          },
        },
      })
    end,
  },

  -- lazydev.nvim
  {
    "lazydev.nvim",
    after = function()
      require("lazydev").setup({
        ft = "lua", -- only load on lua files
      })
    end,
  },
})
