local M = {}

local config = require("smart-backspace.config")

---Checks if the current buffer's filetype has been marked as disabled
function M.check_if_filetype_disabled()
  local disabled_filetypes = config.get_config().disabled_filetypes

      if not vim.g.smart_backspace_enabled then
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

---Setup function to create nvim commands and autocommands
function M.setup()
  vim.api.nvim_create_user_command(
    "SmartBackspaceToggle",
    function(opts)
      local arguements = opts.fargs

      if (#arguements == 0) then
        vim.g.smart_backspace_toggled = not vim.g.smart_backspace_toggled

        if not config.get_config().silent then
          if vim.g.smart_backspace_toggled == true then
            vim.notify("Smart Backspace Enabled!")
          elseif vim.g.smart_backspace_toggled == false then
            vim.notify("Smart Backspace Disabled!")
          end
        end

      elseif (#arguements == 1) then
        if (arguements[1] == "true" or arguements[1] == "on") then
          vim.g.smart_backspace_toggled = true
          if not config.get_config().silent then
            vim.notify("Smart Backspace Enabled!")
          end

        elseif (arguements[1] == "false" or arguements[1] == "off") then
          vim.g.smart_backspace_toggled = false
          if not config.get_config().silent then
            vim.notify("Smart Backspace Disabled!")
          end
        else
          vim.notify("Not a valid state. Try :SmartBackspaceToggle on/off", vim.log.levels.ERROR)
        end

      else
        vim.notify("Please only pass in a maximum of 1 arguement. Try :SmartBackspaceToggle on/off", vim.log.levels.ERROR)
      end
    end,
    {
      desc = "Toggles smart-backspace. Optionally pass in on/off as an arguement to force a specific state",
      nargs = "*",
      complete = function()
        return { "on", "off" }
      end
    }
  )


  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    desc = "Smart-Backspace autocommand to enable/disable on certain filetypes",
    callback = M.check_if_filetype_disabled
  }
)
end

return M
