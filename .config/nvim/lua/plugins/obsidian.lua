-- disabled for now
if true then
  return {}
end

return {

  --
  -- Obsidian
  --
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   "BufReadPre " .. vim.fn.expand '~' .. "workbench/*.md",
    --   "BufNewFile " .. vim.fn.expand '~' .. "workbench/*.md",
    -- },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "workbench",
          path = "~/workbench",
        },
      },
    },
  },
}
