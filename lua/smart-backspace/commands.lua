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
      {}
   )

   local disabled_filetypes = config.get_config().disabled_filetypes

   vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      desc = "Smart-Backspace autocommand to enable/disable on certain filetypes",
      callback = function()
         if (config.get_config().enabled == false) then
            return
         end

         local extension = vim.fn.expand("%:e")
         local is_disabled = false
         for _, filetype in ipairs(disabled_filetypes) do
            if (extension == filetype) then
               is_disabled = true
               break
            end
         end

         if is_disabled then
            vim.g.smart_backspace_toggled = false
         else
            vim.g.smart_backspace_toggled = true
         end
      end
   }
)
end

return M
