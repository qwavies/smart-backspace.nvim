local M = {}

function M.setup()
   -- TODO: set up toggle function
   vim.api.nvim_create_user_command(
      "SmartBackspaceToggle",
      function()
         vim.print("TODO!")
      end,
      {}
   )
end

return M
