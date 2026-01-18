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

  commands.check_if_filetype_disabled()

  vim.defer_fn(function()
    local current_backspace_map = vim.fn.maparg("<BS>", 'i', false, true)
    if (current_backspace_map.callback ~= backspace.smart_backspace) then
      vim.notify("WARNING: Your Smart-Backspace mapping has been overriden. Check which file/plugin has overriden by running `:imap <BS>`", vim.log.levels.WARN)
    end
  end, 500)
end

return M
