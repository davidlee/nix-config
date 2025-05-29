return {

  -- 
  -- treesitter
  --
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    build = ':TSUpdate',
    dependencies = { 
      "nvim-treesitter/nvim-treesitter", 
      "OXY2DEV/markview.nvim", -- load order
    },
  },

  --
  -- tree pairs
  --
  "yorickpeterse/nvim-tree-pairs",

}
