local md = require("mini.deps")
local lz = require("lze")
--
-- UI
require("plenary")
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.git").setup()
require("mini.diff").setup()
require("mini.statusline").setup({
  use_icons = true,
})

lz.load({
  -- which-key
  {
    "which-key.nvim",
    keys = require("config.keymap").which_key.keys,
    lazy = false,
    after = function() require("which-key").add(require("config.keymap").which_key.headings) end,
  },
})

require("plugins.snacks")

lz.load({

  -- gitsigns
  {
    "gitsigns.nvim",

    after = function() require("gitsigns").setup() end,
  },

  -- bufferline
  {
    "bufferline.nvim",
    after = function() require("bufferline").setup() end,
  },

  -- nvim-notify
  {
    "nvim-notify",
    after = function() require("notify").setup() end,
  },

  -- noice
  {
    "noice.nvim",
    after = function()
      require("noice").setup({
        notify = { enabled = false },
        presets = {
          long_message_to_split = true,
          command_palette = true,
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
      })
    end,
  },

  -- navic
  {
    "nvim-navic",
    after = function() require("nvim-navic").setup() end,
  },

  -- smart-splits
  {
    "smart-splits.nvim",
    after = function() require("smart-splits").setup() end,
  },

  -- edgy
  {
    "edgy.nvim",
    after = function() require("edgy").setup() end,
  },

  -- smear-cursor
  {
    "smear-cursor.nvim",
    after = function()
      local smear = require("smear_cursor")
      smear.enabled = true -- requires eg cascadia code
      smear.legacy_computing_symbols_support = true
    end,
  },
})

-- require("plugins.heirline")
