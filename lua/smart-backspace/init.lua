local M = {}

local backspace = require("smart-backspace.backspace")

local config = require("smart-backspace.config")
local commands = require("smart-backspace.commands")

function M.setup(opts)
   vim.g.smart_backspace_loaded = true
   config.setup(opts)
   commands.setup()

   vim.keymap.set("i", "<BS>", backspace.smart_backspace, { desc = "Smart backspace"})
   vim.keymap.set("i", "<C-BS>", backspace.regular_backspace, { desc = "Simple backspace"})
end

return M
