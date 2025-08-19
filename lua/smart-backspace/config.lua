local M = {}

local config = {
   -- TODO: default config
}

function M.setup(opts)
   config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.get_config()
   return config
end

return M
