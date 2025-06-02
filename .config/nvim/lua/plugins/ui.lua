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

  -- gitsigns
  {
    "gitsigns.nvim",

    after = function()
      require("gitsigns").setup()
    end,
  },

  -- bufferline
  {
    "bufferline.nvim",
    after = function()
      require("bufferline").setup()
    end,
  },

  -- lualine
  {
    "lualine.nvim",
    after = function()
      require("lualine").setup({
        -- sections = {
        --   lualine_c = {
        --     "lsp_progress",
        --   },
        -- },
      })
    end,
  },

  -- TODO: https://github.com/arkav/lualine-lsp-progress
  {
    "lualine-lsp-progress",
  },
})

require("plugins.snacks")
-- require("plugins.heirline")
