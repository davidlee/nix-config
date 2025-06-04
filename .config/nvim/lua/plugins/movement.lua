-- movement
require("lze").load({
  -- flash
  {
    "flash.nvim",
    keys = require("config.keymap").flash.keys,
    after = function() require("flash").setup() end,
  },
  {
    -- aerial
    "aerial.nvim",
    after = function()
      local aerial = require("aerial")

      aerial.setup({
        -- use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = require("config.keymap").aerial.on_attach,
      })
    end,
  },
})
