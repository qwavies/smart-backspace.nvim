local M = {}

local config = {
   enabled = true, -- enables/disables smart-backspace
   silent = true, -- if set to false, it will send a notification if smart-backspace is toggled
   disabled_filetypes = { -- filetypes to automatically disable smart backspace
      "py",
      "hs",
      "md",
      "txt",
   }
}

function M.setup(opts)
   config = vim.tbl_deep_extend("force", config, opts or {})

   if config.enabled then
      vim.g.smart_backspace_toggled = true
   else
      vim.g.smart_backspace_toggled = false
   end
end

function M.get_config()
   return config
end

return M
