-- UII
require("plenary")
require("lze").load({

  -- icons
  {
    "mini.icons",
    after = function()
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },

  -- which-key
  {
    "which-key.nvim",
    keys = require("config.keymap").which_key.keys,
    lazy = false,
    after = function() require("which-key").add(require("config.keymap").which_key.headings) end,
  },

  -- TODO: plenary
  {},
})

require("plugins.snacks")

require("lze").load({

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
    after = function() require("notify").setup({}) end,
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

  -- lualine
  -- TODO: replace lualine with:
  -- require("plugins.heirline")
  {
    "lualine.nvim",
    after = function() require("lualine").setup({}) end,
  },
  {
    "lualine-lsp-progress",
  },
})
