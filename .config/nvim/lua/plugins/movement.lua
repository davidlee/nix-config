return {

  --
  -- clever f
  -- 
	"rhysd/clever-f.vim",

  --
  -- arrow 
  --

   {
      "otavioschwanck/arrow.nvim",
      dependencies = {
        { "nvim-tree/nvim-web-devicons" },
        { "echasnovski/mini.icons" },
      },
      opts = {
        show_icons = true,
        leader_key = '-', -- Recommended to be a single key
        buffer_leader_key = 'm', -- Per Buffer Mappings
      }
    },

  --
  -- fzf-lua
  -- 
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
 
  --
  -- Aerial
  --
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
  },


  --
  -- Flash
  --
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
