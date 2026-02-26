local lz = require("lze")

lz.load({
  -- lazydev
  {
    "LazyDev.nvim",
    after = function()
      require("lazydev").setup({
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          { path = "snacks.nvim", words = { "Snacks" } },
        },
        integrations = {
          cmp = false,
        },
      })
    end,
  },

  -- blink.cmp
  {
    "blink.compat",
    lazy = false, -- for lazydev.integrations.blink
  },
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
})
