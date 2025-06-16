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
