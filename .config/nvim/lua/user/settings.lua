-- respect funky comments in comments at top / end of files
vim.o.modeline = true

-- Tab set to two spaces
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

-- Visual aids
vim.o.number = true
vim.o.relativenumber = true
vim.o.hlsearch = true
vim.o.colorcolumn = "80"
vim.o.listchars = "tab:»·,trail:·,extends:>,precedes:<,nbsp:+"  

-- Wrapping
vim.o.wrap = false
vim.o.breakindent = true

-- Keep lines below cursor when scrolling
vim.o.scrolloff = 2
vim.o.sidescrolloff = 5

-- Enable cursorline
vim.o.cursorline = true

-- Always display signcolumn (for diagnostics)
vim.o.signcolumn = 'yes'

-- When opening a window put it right or below the current one
vim.o.splitright = true
vim.o.splitbelow = true

-- Enable mouse support
vim.o.mouse = 'a'

-- Insert mode completion setting
vim.o.completeopt = 'menu,menuone'

-- Use the pretty colors
vim.o.termguicolors = true
vim.o.showmode = true

-- Disable markdown tab settings
vim.g.markdown_recommended_style = 0

-- Number of lines for small windows
vim.g.env_small_screen = 20

-- Ignore the case when the search pattern is all lowercase
vim.o.smartcase = true
vim.o.ignorecase = true

-- Don't use temp files
vim.o.swapfile = false
vim.o.backup = false

-- Neovim specific settings
vim.o.icm = 'split'
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

-- Use rg
vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
vim.opt.grepformat = vim.opt.grepformat ^ { "%f:%l:%c:%m" }

-- concealLevel
vim.opt.conceallevel = 1 -- show one char 
