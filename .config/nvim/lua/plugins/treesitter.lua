require("lze").load({
  {
    "nvim-treesitter.configs",
    after = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
      })
    end,
  },
})
