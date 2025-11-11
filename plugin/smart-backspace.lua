vim.defer_fn(function()
   if vim.g.smart_backspace_loaded then
      return
   else
      vim.g.smart_backspace_loaded = true
   end

   require("smart-backspace").setup()
end, 10)
