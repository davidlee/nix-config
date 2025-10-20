local md = require("mini.deps")
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
      local aerial = require("aerial")

      aerial.setup({
        on_attach = require("config.keymap").aerial.on_attach,
      })
    end,
  },
})

md.add("ibhagwan/fzf-lua")
md.later(function() require("fzf-lua") end)
