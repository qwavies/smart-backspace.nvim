vim.defer_fn(function()
   if vim.g.smart_backspace_loaded then
      return
   else
      require("smart-backspace").setup()
      vim.g.smart_backspace_loaded = true
   end
end, 10)
