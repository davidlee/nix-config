return {
  --
  -- defaults
  --
  { 
		"tpope/vim-sensible",
		opts = { lazy = false },
    config = function () end,
  },

  --
  -- discover keybinds 
  --
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  --
  -- timers
  -- 
  {
    "epwalsh/pomo.nvim",
    version = "*",  -- Recommended, use latest release instead of latest commit
    lazy = true,
    cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
    dependencies = {
      "rcarriga/nvim-notify",
    },
    opts = {
      -- See below for full list of options 👇
    },
  },

  --
  -- git / SCM / diff
  --
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "sindrets/diffview.nvim",
  "akinsho/git-conflict.nvim",

  --
  -- unix
  --
  "tpope/vim-eunuch",

  --
  -- files: oil.nvim
  --
  "stevearc/oil.nvim",


  --
  -- Tree
  --
   {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      -- fill any relevant options here
    },
  },

}

