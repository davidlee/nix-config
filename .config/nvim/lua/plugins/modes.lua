return {

  -- 
  -- Outliner
  --
	"vimoutliner/vimoutliner",
	{
  'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    config = function()
      -- Setup orgmode
      require('orgmode').setup({
        org_agenda_files = '~/org/**/*',
        org_default_notes_file = '~/org/refile.org',
      })
    end,
  },

  --
  -- Markview
  --
  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    opts = {
      preview = {
        icon_provider = "mini", -- "mini" or "devicons"
      },
    },

    dependencies = {
      "saghen/blink.cmp"
    },
  },
  
  -- markdown
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {},
  -- },

  --
  --
  -- Obsidian
  --
  {
    "epwalsh/obsidian.nvim",
    version = "*",  -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   "BufReadPre " .. vim.fn.expand '~' .. "workbench/*.md",
    --   "BufNewFile " .. vim.fn.expand '~' .. "workbench/*.md",
    -- },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "workbench",
          path = "~/workbench",
        },
      },
    },
  },

}
