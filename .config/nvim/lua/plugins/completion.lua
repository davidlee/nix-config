-- completion
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
    ft = "lua",
    cmd = "LazyDev",
    after = function()
      require("lazydev").setup({
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          { path = "LazyVim", words = { "LazyVim" } },
          { path = "snacks.nvim", words = { "Snacks" } },
          { path = "lazy.nvim", words = { "LazyVim" } },
        },
      })
    end,
  },
})
