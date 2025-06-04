require("lze").load({
  -- trouble
  "trouble.nvim",
  after = function()
    require("trouble").setup({
      cmd = "Trouble",
      keys = require("config.keymap").trouble.keys,
    })
  end,
})
