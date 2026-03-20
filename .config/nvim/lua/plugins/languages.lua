local lz = require("lze")

lz.load({
  -- outline
  {
    "outline.nvim",
    after = function() require("outline").setup() end,
  },

  -- TypeScript auto-closing tags
  -- https://github.com/windwp/nvim-ts-autotag
  {
    "nvim-ts-autotag",
    after = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
        per_filetype = {
          ["html"] = {
            enable_close = false,
          },
        },
      })
    end,
  },

  -- d2 diagrams
  { "d2-vim" },

  -- kanban
  -- {
  --   "super-kanban.nvim",
  --   after = function()
  --     require("super-kanban").setup({
  --       markdown = {
  --         notes_dir = "~/kanban/",
  --         list_heading = "h2",
  --         default_template = {
  --           "## Backlog\n",
  --           "## Todo\n",
  --           "## Work in progress\n",
  --           "## Completed\n",
  --         },
  --       },
  --       mappings = {
  --         ["<cr>"] = "open_note",
  --         ["gD"] = "delete_card",
  --         ["<C-t>"] = "toggle_complete",
  --       },
  --     })
  --   end,
  -- },

  -- slim templates
  { "vim-slim" },
})

-- You can place this bit in ~/.config/nvim/init.lua
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.slim" },
  command = "set ft=slim",
})
