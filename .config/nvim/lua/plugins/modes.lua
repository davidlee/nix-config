local md = require("mini.deps")
local lz = require("lze")

-- markdown checklists
require("plugins.checkmate")
require("plugins.render-markdown")
require("plugins.zk")
-- require("plugins.neorg")

-- TODO: set up providers
md.add({ source = "hedyhli/outline.nvim" })
md.later(function() require("outline").setup() end)

-- md.add({
--   source = "vimoutliner/vimoutliner",
-- })
-- md.later(function() require("vimoutliner") end)

-- TypeScript auto-closing tags
-- https://github.com/windwp/nvim-ts-autotag
md.add("windwp/nvim-ts-autotag")
md.later(function()
  require("nvim-ts-autotag").setup({
    opts = {
      -- Defaults
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = false, -- Auto close on trailing </
    },
    -- Also override individual filetype configs, these take priority.
    -- Empty by default, useful if one of the "opts" global settings
    -- doesn't work well in a specific filetype
    per_filetype = {
      ["html"] = {
        enable_close = false,
      },
    },
  })
end)
