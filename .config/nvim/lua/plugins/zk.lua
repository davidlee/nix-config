-- https://github.com/zk-org/zk-nvim

local lz = require("lze")

lz.load({
  "zk-nvim",
  after = function()
    require("zk").setup({
      picker = "snacks",
      lsp = {
        config = {
          name = "zk",
          cmd = { "zk", "lsp" },
          filetypes = { "markdown" },
          -- on_attach = ...
          -- etc, see `:h vim.lsp.start()`
        },

        auto_attach = {
          enabled = true,
        },
      },
    })
  end,
})
