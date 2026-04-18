local M = {}

--- @class SmartBackspaceConfig
--- @field enabled? boolean Enables or disables smart-backspace. Defaults to `true`.
--- @field silent? boolean If `false`, sends a notification when smart-backspace is toggled. Defaults to `true`.
--- @field disabled_filetypes? string[] List of filetypes to automatically disable smart-backspace for. Defaults to `{ "", "py", "hs", "md", "txt" }`.

--- @type SmartBackspaceConfig
local config = {
  enabled = true, -- enables/disables smart-backspace
  silent = true, -- if set to false, it will send a notification if smart-backspace is toggled
  disabled_filetypes = { -- filetypes to automatically disable smart backspace
    "",
    "py",
    "hs",
    "md",
    "txt",
  }
}

--- Setup function to process configuration
--- @param opts? SmartBackspaceConfig the user's config
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enabled then
    vim.g.smart_backspace_enabled = true
    vim.g.smart_backspace_toggled = true
  else
    vim.g.smart_backspace_enabled = false
    vim.g.smart_backspace_toggled = false
  end
end

--- Returns the user's current config
--- @return SmartBackspaceConfig config the user's current config
function M.get_config()
  return config
end

return M
