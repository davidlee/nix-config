---
--- Mini
---

require('mini.ai').setup()         -- a/i textobjects
require('mini.align').setup()      -- aligning
require('mini.bracketed').setup()  -- unimpaired bindings with TS
require('mini.comment').setup()    -- TS-wise comments
require('mini.icons').setup()      -- minimal icons
-- require('mini.jump').setup()       -- fFtT work past a line
require('mini.pairs').setup()      -- pair brackets
-- require('mini.statusline').setup() -- minimal statusline
require('mini.surround').setup({   -- surround
  custom_surroundings = {
    ['l'] = { output = { left = '[', right = ']()'}}
  }
})
require('mini.clue').setup({})     -- cute prompts about bindings

local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  snippets = {
    -- Load custom file with global snippets first 
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})

