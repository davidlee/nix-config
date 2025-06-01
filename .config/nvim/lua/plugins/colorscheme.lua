return {
  --
  -- Themes (activated here)
  --

  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {},
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },

  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    opts = {},
  },

  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_enable_italic = true
    end,
  },

  {
    "NLKNguyen/papercolor-theme",
    lazy = false,
    priority = 1000,
  },

  -- Configure LazyVim to load our preferred colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "gruvbox-material",
      -- colorscheme = "gruvbox",
      -- colorscheme = "papercolor",
      colorcsheme = "habamax",
    },
  },
}
