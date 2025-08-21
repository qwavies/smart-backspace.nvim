local M = {}

local function contains_only_whitespace(str)
   for char in str:gmatch(".") do
      if char ~= " " and char ~= "\t" then
         return false
      end
   end
   return true
end

local function remove_whitespace(cursor_pos, current_line)
   local row = cursor_pos[1] - 1
   local col = cursor_pos[2]
   local after_cursor = current_line:sub(col + 1)

   local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

   if (row > 0) and (contains_only_whitespace(prev_line)) then
      -- edge case where line above is empty
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {}) -- simply remove above line
   elseif (row > 0) then
      local new_line = prev_line .. after_cursor
      vim.api.nvim_buf_set_lines(0, row - 1, row + 1, false, {new_line}) -- replace both lines w new_line
      vim.api.nvim_win_set_cursor(0, {row, #prev_line}) -- set cursor at end of previous line content
   else
      -- if just on line 1, just delete from start to cursor
      vim.api.nvim_buf_set_lines(0, 0, 1, false, {after_cursor})
      vim.api.nvim_win_set_cursor(0, {1, 0})
   end
end

function M.smart_backspace()
   local current_line = vim.api.nvim_get_current_line()
   local cursor_pos = vim.api.nvim_win_get_cursor(0)

   local behind_cursor = current_line:sub(1, cursor_pos[2])

   if contains_only_whitespace(behind_cursor) then
      remove_whitespace(cursor_pos, current_line)
   else
      -- normal backspace behaviour
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", true)
   end
end

function M.regular_backspace()
   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", true)
end

return M
