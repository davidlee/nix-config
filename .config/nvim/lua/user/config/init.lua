--
-- Config: require & setup for plugins that have by now been lazy-loaded
--

vim.cmd.colorscheme('gruvbox')

require('user.config.kinetics')
require('user.config.semantics')
require('user.config.aesthetics')
require('user.config.linguistics')

--------------------------------------------------------------------------------
--- see https://evantravers.com/articles/2024/09/17/making-my-nvim-act-more-like-helix-with-mini-nvim

---
--- Mini
---

require('mini.ai').setup()         -- a/i textobjects
require('mini.align').setup()      -- aligning
require('mini.bracketed').setup()  -- unimpaired bindings with TS
require('mini.comment').setup()    -- TS-wise comments
require('mini.icons').setup()      -- minimal icons
require('mini.jump').setup()       -- fFtT work past a line
require('mini.pairs').setup()      -- pair brackets
-- require('mini.statusline').setup() -- minimal statusline
require('mini.surround').setup({   -- surround
  custom_surroundings = {
    ['l'] = { output = { left = '[', right = ']()'}}
  }
})
require('mini.clue').setup({})     -- cute prompts about bindings


