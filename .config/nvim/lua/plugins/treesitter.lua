-- local md = require("mini.deps")
local lz = require("lze")
--
-- md.add({
--   source = "nvim-treesitter/nvim-treesitter",
--   lazy = false,
--   -- checkout = "master",
--   -- monitor = "main",
--   checkout = "main",
--   build = ":TSUpdate",
--   hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
--   config = function()
--     ---
--     ---
--   end,
-- })
--

lz.load({
  {
    -- nvim-treesitter
    "nvim-treesitter",
    after = function()
      require("nvim-treesitter").setup({
        highlight = { enable = true },
      })

      require("nvim-treesitter.configs").setup({
        ensure_installed = { "zig" },
        highlight = { enable = true },
      })
    end,
  },
})
require("nvim-treesitter").setup({
  ensure_installed = { "all" },
  highlight = { enable = true },
})
require("nvim-treesitter.configs").setup({
  -- ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true, -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
  },
})
-- -- configuration
-- require("nvim-treesitter-textobjects").setup({
--   select = {
--     -- Automatically jump forward to textobj, similar to targets.vim
--     lookahead = true,
--     -- You can choose the select mode (default is charwise 'v')
--     --
--     -- Can also be a function which gets passed a table with the keys
--     -- * query_string: eg '@function.inner'
--     -- * method: eg 'v' or 'o'
--     -- and should return the mode ('v', 'V', or '<c-v>') or a table
--     -- mapping query_strings to modes.
--     selection_modes = {
--       ["@parameter.outer"] = "v", -- charwise
--       ["@function.outer"] = "V", -- linewise
--       -- ['@class.outer'] = '<c-v>', -- blockwise
--     },
--     -- If you set this to `true` (default is `false`) then any textobject is
--     -- extended to include preceding or succeeding whitespace. Succeeding
--     -- whitespace has priority in order to act similarly to eg the built-in
--     -- `ap`.
--     --
--     -- Can also be a function which gets passed a table with the keys
--     -- * query_string: eg '@function.inner'
--     -- * selection_mode: eg 'v'
--     -- and should return true of false
--     include_surrounding_whitespace = false,
--   },
-- })

--
-- md.now(
--   function()
--     require("nvim-treesitter").setup({
--       ensure_installed = { "lua", "vimdoc", "zig" },
--       highlight = { enable = true },
--     })
--   end
-- )
--
-- md.add({
--   source = "nvim-treesitter/nvim-treesitter-textobjects",
--   checkout = "main",
--   after = "nvim-treesitter",
--   requires = "nvim-treesitter",
--   build = ":TSUpdate",
--   init = function() end,
-- })

-- md.later(function()
--   require("nvim-treesitter").setup({
--     highlight = { enable = true },
--   })
-- end)
--
-- md.later(function()
--   -- configuration
--   require("nvim-treesitter-textobjects").setup({
--     select = {
--       -- Automatically jump forward to textobj, similar to targets.vim
--       lookahead = true,
--       -- You can choose the select mode (default is charwise 'v')
--       --
--       -- Can also be a function which gets passed a table with the keys
--       -- * query_string: eg '@function.inner'
--       -- * method: eg 'v' or 'o'
--       -- and should return the mode ('v', 'V', or '<c-v>') or a table
--       -- mapping query_strings to modes.
--       selection_modes = {
--         ["@parameter.outer"] = "v", -- charwise
--         ["@function.outer"] = "V", -- linewise
--         -- ['@class.outer'] = '<c-v>', -- blockwise
--       },
--       -- If you set this to `true` (default is `false`) then any textobject is
--       -- extended to include preceding or succeeding whitespace. Succeeding
--       -- whitespace has priority in order to act similarly to eg the built-in
--       -- `ap`.
--       --
--       -- Can also be a function which gets passed a table with the keys
--       -- * query_string: eg '@function.inner'
--       -- * selection_mode: eg 'v'
--       -- and should return true of false
--       include_surrounding_whitespace = false,
--     },
--   })
-- end)
--
