-- local md = require("mini.deps")
local lz = require("lze")

-- snacks
lz.load({
  {
    "snacks.nvim",
    -- there's prolly a faster loading way to make sure it happens before VimEnter
    -- lazy = false,
    after = function()
      Snacks.setup({
        dashboard = {
          enabled = false,
        },
        notifier = {},
        profiler = {},
        scratch = {},
        rename = {},
        statuscolumn = {},
        scope = {},
        explorer = {
          replace_netrw = false,
        },
        terminal = {},
        picker = {},
        quickfile = {},
        bigfile = {},
        image = {},
        words = {},
        input = {},
        toggle = {},
        dim = {},
        indent = {},
        win = {},
        git = {},
        debug = {},
      })
    end,

    keys = require("config.keymap").snacks.keys,
  },
})
