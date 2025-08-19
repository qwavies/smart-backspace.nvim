local M = {}

local config = require("smart-backspace.config")
local backspace = require("smart-backspace.backspace")
local commands = require("smart-backspace.commands")

function M.setup(opts)
   config.setup(opts)

   vim.keymap.set("i", "<BS>", backspace.smart_backspace, { desc = "Smart backspace"})
   vim.keymap.set("i", "<C-BS>", backspace.regular_backspace, { desc = "Simple backspace"})
end

return M
