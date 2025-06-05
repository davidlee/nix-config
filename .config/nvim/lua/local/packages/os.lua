-- local.packages.os
local M = {}

local sh_word = require("local.packages.shell").sh_word

-- is this a mac?
function M.is_mac() return sh_word("uname -o") == "Darwin" end

function M.is_linux() return not M.is_mac() end

return M
