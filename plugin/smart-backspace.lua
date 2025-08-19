if vim.g.smart_backspace_loaded then
   return
end
vim.g.smart_backspace_loaded = 1

vim.defer_fn(function()
   require("smart-backspace").setup()
end, 10)
