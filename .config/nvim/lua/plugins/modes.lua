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

md.add("ray-x/go.nvim")
md.later(function()
  require("go").setup({})
  local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function() require("go.format").goimports() end,
    group = format_sync_grp,
  })
end)

md.add("terrastruct/d2-vim")
md.later(function()
  -- require("d2") --.setup({
  --ft = "d2",
  --})
end)

md.add({
  source = "hasansujon786/super-kanban.nvim",
  depends = {
    { source = "folke/snacks.nvim" }, -- [required]
    { source = "nvim-orgmode/orgmode" }, -- [optional]
  },
})
md.later(
  function()
    require("super-kanban").setup({
      markdown = {
        notes_dir = "~/kanban/",
        list_heading = "h2",
        default_template = {
          "## Backlog\n",
          "## Todo\n",
          "## Work in progress\n",
          "## Completed\n",
        },
      },
      mappings = {
        ["<cr>"] = "open_note",
        ["gD"] = "delete_card",
        ["<C-t>"] = "toggle_complete",
      },
    })
  end
)

-- You can place this bit in ~/.config/nvim/init.lua
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.slim" },
  command = "set ft=slim",
})
md.add("slim-template/vim-slim")
md.later()
