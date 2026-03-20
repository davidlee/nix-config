-- vim.pack.add (packfile.lua) handles plugin installation
-- lze handles lazy-loading and configuration
-- nix provides: lze, blink-cmp (binary deps), themes, bootstrapping

require("plugins.lsp")
require("plugins.ui")
require("plugins.editor")
require("plugins.movement")
require("plugins.amenities")
require("plugins.format")
require("plugins.file_managers")
require("plugins.completion")
require("plugins.highlight")
require("plugins.lint")
require("plugins.trouble")
require("plugins.languages")
require("plugins.render-markdown")
require("plugins.zk")
require("plugins.snippets")
