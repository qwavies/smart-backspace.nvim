local M = {}

local config = {
   enabled = true,
   silent = true,
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
