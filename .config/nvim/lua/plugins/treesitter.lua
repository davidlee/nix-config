require("lze").load({
  {
    -- "nvim-treesitter.configs",
    "nvim-treesitter",
    after = function()
      require("nvim-treesitter").setup({
        highlight = { enable = true },
      })
    end,
  },
})
