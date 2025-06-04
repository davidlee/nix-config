-- UI

require("lze").load({

  -- icons
  {
    "mini.icons",
    after = function()
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },

  -- vim-illuminate
  {
    "vim-illuminate",
    after = function()
      require("illuminate").configure({
        --
      })
    end,
  },

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

  -- lualine
  {
    "lualine.nvim",
    after = function() require("lualine").setup({}) end,
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

  -- TODO: or do heirline instead https://github.com/arkav/lualine-lsp-progress
  {
    "lualine-lsp-progress",
  },
})

-- make sure icons have loaded before snacks
require("plugins.snacks")
-- ultimately, replace lualine with:
-- require("plugins.heirline")
