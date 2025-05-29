local presets = require("markview.presets");

require("markview").setup({
  markdown = {
    headings = presets.headings.glow
  }
});
