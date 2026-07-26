-- nvim-treesitter `main` branch.
--   * plugin + queries: loaded by vim.pack.add (packfile.lua)
--   * parsers: compiled on demand into stdpath('data')/site, using the
--     `tree-sitter` CLI + gcc supplied via nix (flakes: nvim-plugins.nix `deps`)
--   * highlighting: a core Neovim feature, enabled per-buffer below.
-- The `main` branch dropped `nvim-treesitter.configs` (ensure_installed /
-- highlight.enable); those are replaced by `.install{}` and vim.treesitter.start.

local ts = require("nvim-treesitter")

local ensure = {
  "bash", "css", "go", "html", "javascript", "json", "lua", "markdown",
  "markdown_inline", "nix", "python", "ruby", "rust", "svelte", "toml",
  "tsx", "typescript", "vim", "vimdoc", "yaml", "zig",
}

-- install missing parsers (async; .install is a no-op for present langs)
local have = {}
for _, l in ipairs(ts.get_installed()) do
  have[l] = true
end
local missing = vim.tbl_filter(function(l)
  return not have[l]
end, ensure)
if #missing > 0 then
  ts.install(missing)
end

-- Enable treesitter highlighting (+ injections) for every buffer whose
-- filetype has a parser. pcall guards filetypes without one (oil, prompts).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dl_treesitter", { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

require("treesitter-context").setup({})

-- syntax-aware text objects, motions, and swaps (nvim-treesitter-textobjects)
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@parameter.outer"] = "v",
      ["@function.outer"] = "V",
    },
  },
})

local ts_select = require("nvim-treesitter-textobjects.select")
local ts_move = require("nvim-treesitter-textobjects.move")
local ts_swap = require("nvim-treesitter-textobjects.swap")

-- select: a=around / i=inside, over function / class / parameter / loop
for lhs, obj in pairs({
  ["af"] = "@function.outer",
  ["if"] = "@function.inner",
  ["ac"] = "@class.outer",
  ["ic"] = "@class.inner",
  ["aa"] = "@parameter.outer",
  ["ia"] = "@parameter.inner",
  ["al"] = "@loop.outer",
  ["il"] = "@loop.inner",
}) do
  vim.keymap.set({ "x", "o" }, lhs, function()
    ts_select.select_textobject(obj, "textobjects")
  end, { desc = "TS select " .. obj })
end

-- move: ]/[ to next/prev node start; ]F/[F for function end
for lhs, spec in pairs({
  ["]f"] = { ts_move.goto_next_start, "@function.outer", "next function" },
  ["[f"] = { ts_move.goto_previous_start, "@function.outer", "prev function" },
  ["]F"] = { ts_move.goto_next_end, "@function.outer", "next function end" },
  ["[F"] = { ts_move.goto_previous_end, "@function.outer", "prev function end" },
  ["]c"] = { ts_move.goto_next_start, "@class.outer", "next class" },
  ["[c"] = { ts_move.goto_previous_start, "@class.outer", "prev class" },
  ["]a"] = { ts_move.goto_next_start, "@parameter.inner", "next parameter" },
  ["[a"] = { ts_move.goto_previous_start, "@parameter.inner", "prev parameter" },
}) do
  local fn, obj, desc = spec[1], spec[2], spec[3]
  vim.keymap.set({ "n", "x", "o" }, lhs, function()
    fn(obj, "textobjects")
  end, { desc = "TS " .. desc })
end

-- swap: node under cursor with its next/prev sibling parameter
vim.keymap.set("n", "<leader>a", function()
  ts_swap.swap_next("@parameter.inner")
end, { desc = "TS swap next parameter" })
vim.keymap.set("n", "<leader>A", function()
  ts_swap.swap_previous("@parameter.inner")
end, { desc = "TS swap prev parameter" })
