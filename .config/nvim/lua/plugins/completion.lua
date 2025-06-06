-- completion
require("lze").load({
  -- lazydev.nvim
  {
    "lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
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
      require("lazydev.integrations.blink")
    end,
  },

  -- blink.cmp
  {
    "blink.compat",
    lazy = false, -- for lazydev.ingrations.blink
  },
  {
    "blink.cmp",
    after = function()
      -- require("lazydev.integrations.blink")
      require("blink.cmp").setup({
        sources = {
          -- add lazydev to your completion providers
          default = { "lazydev", "lsp", "path", "snippets", "buffer" },
          providers = {
            lazydev = {
              name = "LazyDev",
              -- FIXME: can't seem to make this happy
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
