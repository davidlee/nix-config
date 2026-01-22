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

      -- require("nvim-treesitter.configs").setup({
      --   ensure_installed = { "zig" },
      --   highlight = { enable = true },
      -- })
    end,
  },
})
