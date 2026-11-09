-- Plugin setup. Plugin code: ~/flakes/features/files.nix (nixpkgs)
-- or package.toml (`ya pkg install`).

require("full-border"):setup { set = "rounded" }
require("git"):setup()
require("smart-enter"):setup { open_multi = true }

-- status_line is yatline's default plus the symlink target after the path.
-- Overriding a line replaces it whole, so keep the defaults here.
require("yatline"):setup {
  status_line = {
    left = {
      section_a = { { type = "string", name = "tab_mode" } },
      section_b = { { type = "string", name = "hovered_size" } },
      section_c = {
        { type = "string", name = "hovered_path" },
        { type = "coloreds", name = "symlink" },
        { type = "coloreds", name = "count" },
      },
    },
    right = {
      section_a = { { type = "string", name = "cursor_position" } },
      section_b = { { type = "string", name = "cursor_percentage" } },
      section_c = {
        { type = "string", name = "hovered_file_extension", params = { true } },
        { type = "coloreds", name = "permissions" },
      },
    },
  },
}
require("yatline-symlink"):setup() -- must follow yatline
