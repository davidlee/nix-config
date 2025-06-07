-- local md = require("mini.deps")
local lz = require("lze")

-- markdown
lz.load({

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
