-- markdown
require("lze").load({

  {
    "nvim-lspconfig",
    after = function()
      require("lspconfig")["marksman"].setup({
        --
      })
      -- require("lspconfig")["luals"].setup({ })
    end,
  },
})
