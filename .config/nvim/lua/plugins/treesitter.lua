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
