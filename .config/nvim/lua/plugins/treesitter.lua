-- local md = require("mini.deps")
local lz = require("lze")

lz.load({
  {
    -- nvim-treesitter
    "nvim-treesitter",
    after = function()
      require("nvim-treesitter").setup({
        highlight = { enable = true },
      })
    end,
  },
})
