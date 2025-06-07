local md = require("mini.deps")
local lz = require("lze")

-- HACK: solves the path issue which makes blink unable to load
-- lazydev.integrations.blink - there's potential for issues caused by having
-- it load from a more recent versions of lazyvim, but it seems minor and I
-- spent way too long on this already.
-- TODO: prolly just replace nix lazyvim
md.add({ source = "folke/LazyDev.nvim", name = "lazydev" })
md.later(
  function()
    require("lazydev").setup({
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
      integrations = {
        cmp = false,
      },
    })
  end
)

lz.load({
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
