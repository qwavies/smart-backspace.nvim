local M = {}

local function contains_pair(cursor_pos, current_line)
   local col = cursor_pos[2]

   local code_pairs = {
      { "(" , ")" },
      { "[" , "]" },
      { "{" , "}" },
      { "<" , ">" },
      { "\'" , "\'" },
      { "\"" , "\"" },
   }

   if (col + 1 > #current_line) then
      return false
   end

   local current_character = current_line:sub(col, col)
   local next_character = current_line:sub(col + 1, col + 1) -- is known that its not the last character so always in bounds

   for _, pair in pairs(code_pairs) do
      local opening_pair = pair[1]
      local closing_pair = pair[2]
      if (current_character == opening_pair) and (next_character == closing_pair) then
         return true
      end
   end
   return false
end

local function remove_pair(cursor_pos, current_line)
   local row = cursor_pos[1]
   local col = cursor_pos[2]

   local new_line = current_line:sub(1, col - 1) .. current_line:sub(col + 2)
   vim.api.nvim_set_current_line(new_line)
   vim.api.nvim_win_set_cursor(0, {row, col - 1})
end

local function regular_backspace(cursor_pos, current_line)
   local row = cursor_pos[1]
   local col = cursor_pos[2]

   if (col > 0) then
      -- delete character before
      local new_line = current_line:sub(1, col - 1) .. current_line:sub(col + 1)
      vim.api.nvim_set_current_line(new_line)
      vim.api.nvim_win_set_cursor(0, {row, col - 1})

   elseif (row > 1) then
      -- at start of line, join with previous line
      local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
      local new_line = prev_line .. current_line
      vim.api.nvim_buf_set_lines(0, row - 2, row, false, {new_line})
      vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line})
   end
   -- edge case: on line 1 first character, do nothing
end

local function contains_only_whitespace(str)
   for char in str:gmatch(".") do
      if char ~= " " and char ~= "\t" then
         return false
      end
   end
   return true
end

local function count_whitepsace(str)
   local tabs_to_spaces_ratio = vim.api.nvim_get_option_value("tabstop", { buf = 0 })
   local count = 0

   for char in str:gmatch(".") do
      if char == " " then
         count = count + 1
      elseif char == "\t" then
         count = count + tabs_to_spaces_ratio
      else
         -- non-whitespace character
         return count
      end
   end

   return count
end

local function remove_whitespace(cursor_pos, current_line)
   local row = cursor_pos[1] - 1
   local col = cursor_pos[2]
   local after_cursor = current_line:sub(col + 1)

   local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

   if (row == 0) then
      -- edge case: if on line 1, just delete from start to cursor
      vim.api.nvim_buf_set_lines(0, 0, 1, false, {after_cursor})
      vim.api.nvim_win_set_cursor(0, {1, 0})

   elseif (row > 0) and (contains_only_whitespace(prev_line)) then
      -- edge case: line above is empty
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {}) -- simply remove above line

   elseif (row > 0) and (prev_line:sub(-1) == ";") and (count_whitepsace(current_line) > count_whitepsace(prev_line)) then
      -- edge case: above prev_line ends (denoted with ;) and current_line is over-indented
      -- TODO: check if replacing with for loop is better for 
      local prev_line_whitespace = prev_line:match("^(%s+)")
      vim.api.nvim_buf_set_lines(0, row, row + 1, false, {prev_line_whitespace .. after_cursor})
      vim.api.nvim_win_set_cursor(0, {row + 1, #prev_line_whitespace})

   elseif (row > 0) then
      local new_line = prev_line .. after_cursor
      vim.api.nvim_buf_set_lines(0, row - 1, row + 1, false, {new_line}) -- replace both lines w new_line
      vim.api.nvim_win_set_cursor(0, {row, #prev_line}) -- set cursor at end of previous line content

   else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", true)
   end
end

function M.smart_backspace()
   local current_line = vim.api.nvim_get_current_line()
   local cursor_pos = vim.api.nvim_win_get_cursor(0)
   local behind_cursor = current_line:sub(1, cursor_pos[2])

   if contains_only_whitespace(behind_cursor) then
      remove_whitespace(cursor_pos, current_line)

   elseif contains_pair(cursor_pos, current_line) then
      remove_pair(cursor_pos, current_line)

   else
      regular_backspace(cursor_pos, current_line)
   end
end

function M.regular_backspace()
   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", true)
end

return M
