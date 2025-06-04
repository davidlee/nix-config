-- markdown
require("lze").load({

  {
    "nvim-lspconfig",
    after = function()
      require("lspconfig")["marksman"].setup({
        --
      })
    end,
  },
})
