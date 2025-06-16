local md = require("mini.deps")
local lz = require("lze")

-- markdown
lz.load({

  {
    "nvim-lspconfig",
    after = function()
      require("lspconfig")["marksman"].setup({
        --
      })
      require("lspconfig")["luals"].setup({})
    end,
  },
})

-- eagle (diagnostics + LSP info on cursor)
md.add({ source = "soulis-1256/eagle.nvim" })

md.later(function() require("eagle").setup({}) end)
