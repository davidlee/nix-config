local lz = require("lze")

-- movement
lz.load({
  -- flash
  {
    "flash.nvim",
    keys = require("config.keymap").flash.keys,
    after = function() require("flash").setup() end,
  },

  -- aerial
  {
    "aerial.nvim",
    after = function()
      require("aerial").setup({
        on_attach = require("config.keymap").aerial.on_attach,
      })
    end,
  },

  -- fzf-lua
  {
    "fzf-lua",
    after = function() require("fzf-lua") end,
  },
})
