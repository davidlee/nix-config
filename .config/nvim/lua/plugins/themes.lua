return {
  --
  -- Themes (activated here)
  --

  -- { 'ellisonleao/gruvbox.nvim', 
  --   priority = 1000, 
  --   config = true, 
  --   opts = {},
  --   config = function()
  --     vim.cmd.colorscheme('gruvbox')
  --   end, 
  -- },

  { 'folke/tokyonight.nvim', 
    lazy = false, 
    priority = 1000, 
    config = true, 
    opts = {}, 
    config = function()
      -- vim.cmd.colorscheme('tokyonight-dark')
    end, 
  },

  { 
    'sainnhe/sonokai', 
    lazy = false, 
    priority = 1000, 
    opts = {}, 
    config = function()
      vim.cmd.colorscheme('sonokai')
    end, 
  },

  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_enable_italic = true
      -- vim.cmd.colorscheme('gruvbox-material')
    end
  },

  {
   'NLKNguyen/papercolor-theme',
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme('papercolor')
    end
  },
 
} 
