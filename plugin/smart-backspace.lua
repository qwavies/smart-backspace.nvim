vim.defer_fn(function()
   if vim.g.smart_backspace_loaded then
      return
   end
   vim.g.smart_backspace_loaded = true

   require("smart-backspace").setup()
end, 10)
