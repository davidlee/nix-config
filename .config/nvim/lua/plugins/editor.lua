return {

  --
  -- learn through masochism 
  --
  {
     "m4xshen/hardtime.nvim",
     lazy = false,
     dependencies = { "MunifTanjim/nui.nvim" },
     opts = {
      restriction_mode = "hint",
      disable_mouse = false,
      restricted_keys = {
        ["<Left>"] = { 'n', 'x' },
        ["<Right>"] = { 'n', 'x' },
        ["<Down>"] = { 'n', 'x' },
        ["<Up>"] = { 'n', 'x' },
      },
      disabled_keys = {
        ["<Left>"] = false,
        ["<Right>"] = false,
        ["<Down>"] = false,
        ["<Up>"] = false,
      },
    },
  }, 

  --
  -- extended action targets
  --
  "wellle/targets.vim",

  --
  -- date & time increments 
  -- 
  "tpope/vim-speeddating",

  --
  -- TODOs
  --
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

}
