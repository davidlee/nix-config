-- snacks
require("lze").load({
  {
    "snacks.nvim",
    after = function()
      Snacks.setup({
        dashboard = {
          enabled = false,
        },
        notifier = {},
        quickfile = {},
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
