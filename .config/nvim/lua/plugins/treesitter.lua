require("lze").load({
  {
    -- nvim-treesitter
    "nvim-treesitter",
    after = function()
      require("nvim-treesitter").setup({
        highlight = { enable = true },
      })
    end,
  },
})
