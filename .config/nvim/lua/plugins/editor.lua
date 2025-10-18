-- local md = require("mini.deps")
local lz = require("lze")

require("mini.surround").setup({
  mappings = require("config.keymap").mini_surround.mappings,
})

-- editor
lz.load({
  -- yanky
  {
    "yanky.nvim",
    after = function() require("yanky").setup() end,
  },

  -- todo-comments
  {
    "todo-comments.nvim",
    after = function() require("todo-comments").setup({}) end,
  },

  {
    "auto-save.nvim",
    after = function() require("auto-save").setup({}) end,
    -- enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
    -- trigger_events = { -- See :h events
    --   immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" }, -- vim events that trigger an immediate save
    --   defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
    --   cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
    -- },
  },
})
