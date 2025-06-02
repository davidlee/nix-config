require("lze").load({
  -- project
  "project.nvim",
  after = function()
    require("project").setup({
      patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "Justfile",
        "Rakefile",
        ".envrc",
        "shell.nix",
      },
      --
    })
  end,
})
