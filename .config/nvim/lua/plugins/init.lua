-- plugins
return {

  -- themes
  { "ellisonleao/gruvbox.nvim", opts = { priority = 1000, config = true, opts = {} }},
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },

  -- noice
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },
  {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},

  -- QoL 
  --
  "folke/which-key.nvim",

  { 
		"tpope/vim-sensible",
		opts = { lazy = false },
    config = function () end,
  },
  -- action targets
  "wellle/targets.vim",
  -- date & time increments 
  "tpope/vim-speeddating",
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },


  -- MINI
  --
	{ 'echasnovski/mini.nvim', version = false },

  -- LATER SOMETIME
	-- "folke/trouble.nvim", -- todo config


  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    build = ':TSUpdate',
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  "yorickpeterse/nvim-tree-pairs",

  -- Jump 
  --
	"rhysd/clever-f.vim",
	{
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
	},
  {
    "ibhagwan/fzf-lua",

		dependencies = { "echasnovski/mini.icons", "mfussenegger/nvim-dap" },
    opts = {
      keymap = { 
        builtin  = { true },
        fzf = { true },
      },
      oldfiles = {
        -- In Telescope, when I used <leader>fr, it would load old buffer
        -- fzf lua does the same, but by default buffers visited in the current
        -- session are not included. I use <leader>fr all the time to switch
        -- back to buffers I was just in. If you missed this from Telescope,
        -- give it a try.
        include_current_session = true,
      },
      previewers = {
        builtin = {
          -- With this change, the previewer will not add syntax highlighting to files larger than 100KB
          -- (Yes, I know you shouldn't have 100KB minified files in source control.)
          syntax_limit_b = 1024 * 100, -- 100KB
        },
      },
      grep = {
        -- One thing I missed from Telescope was the ability to live_grep and the
        -- run a filter on the filenames.
        -- Ex: Find all occurrences of "enable" but only in the "plugins" directory.
        -- With this change, I can sort of get the same behaviour in live_grep.
        -- ex: > enable --*/plugins/*
        -- I still find this a bit cumbersome. There's probably a better way of doing this.
        rg_glob = true, -- enable glob parsing
        glob_flag = "--iglob", -- case insensitive globs
        glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
      },
    },
  },
 
  -- comments
  --
  "tpope/vim-commentary",
  {"folke/todo-comments.nvim", opts = {} },
	
  -- git / SCM / diff
  --
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "sindrets/diffview.nvim",
  "akinsho/git-conflict.nvim",

  -- unix
  --
  "tpope/vim-eunuch",
  
  -- syntax modes
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

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    opts = {},
  },

  -- libs
	"MunifTanjim/nui.nvim",
  'nvim-lua/plenary.nvim',

  -- statusline
	{
		"nvim-lualine/lualine.nvim", 
		dependencies = { 'nvim-tree/nvim-web-devicons' } -- mini.icons ?
	},

  -- aerial
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
  },

}
