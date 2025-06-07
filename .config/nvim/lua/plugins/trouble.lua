-- local md = require("mini.deps")
local lz = require("lze")

lz.load({
  -- folke/trouble
  "trouble.nvim",
  keys = require("config.keymap").trouble.keys,
  after = function()
    require("trouble").setup({
      cmd = "Trouble",
    })
  end,
})
