-- snacks
require("lze").load({
  {
    "snacks.nvim",
    -- event = "VimEnter",
    -- priority = 10,
    lazy = false,
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
