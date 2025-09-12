local M = {}

local config = require("smart-backspace.config")

function M.setup()
   vim.api.nvim_create_user_command(
      "SmartBackspaceToggle",
      function()
         vim.g.smart_backspace_toggled = not vim.g.smart_backspace_toggled

         if not config.get_config().silent then
            if vim.g.smart_backspace_toggled == true then
               vim.notify("Smart Backspace Enabled!")
            elseif vim.g.smart_backspace_toggled == false then
               vim.notify("Smart Backspace Disabled!")
            end
         end
      end,
      {})
end

return M
