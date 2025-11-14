local M = {}

-- UTF-8 safe helper function to delete the character before cursor
-- Returns: (new_line, new_col) or (nil, nil) if nothing to delete
local function delete_char_before_cursor_utf8(line, col)
   if col == 0 then
      return nil, nil
   end

   -- Convert byte index (0-indexed) to character index
   local char_idx = vim.str_utfindex(line, col)

   if (char_idx == 0) then
      return nil, nil
   end

   -- Get byte index of the previous character
   local prev_char_byte_idx = vim.str_byteindex(line, char_idx - 1)

   -- Delete from prev_char_byte_idx to col (exclusive)
   -- In Lua string.sub: keep [1, prev_char_byte_idx] and [col+1, end]
   local new_line = line:sub(1, prev_char_byte_idx) .. line:sub(col + 1)

   return new_line, prev_char_byte_idx
end

local function contains_pair(cursor_pos, current_line)
   local col = cursor_pos[2]

   local code_pairs = {
      { "(" , ")" },
      { "[" , "]" },
      { "{" , "}" },
      { "<" , ">" },
      { "\'" , "\'" },
      { "\"" , "\"" },
      { "`" , "`" },
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

local function remove_charater(cursor_pos, current_line)
   local row = cursor_pos[1]
   local col = cursor_pos[2]

   if (col > 0) then
      -- delete character before cursor (UTF-8 safe)
      local new_line, new_col = delete_char_before_cursor_utf8(current_line, col)
      if new_line then
         vim.api.nvim_set_current_line(new_line)
         vim.api.nvim_win_set_cursor(0, {row, new_col})
      end

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

local function trim_whitespace(whitespace_string, tab_width)
   -- get tab-adjusted size
   local total = 0
   for i = 1, #whitespace_string do
      local char = whitespace_string:sub(i, i)
      if (char == "\t") then
         total = total + tab_width
      elseif (char == " ") then
         total = total + 1
      end
   end

   -- calc target (next lowest multiple of tab_width)
   local target = total - (total % tab_width)
   if (target == total) then
      target = target - tab_width
   end
   if (target < 0) then
      target = 0
   end

   -- Find pos to cut
   local current = 0
   local cut_pos = 0
   for i = 1, #whitespace_string do
      local value = 0
      local char = whitespace_string:sub(i, i)
      if (char == "\t") then
         value = tab_width
      else
         value = 1
      end

      if (current + value) <= target then
         current = current + value
         cut_pos = i
      else
         break
      end
   end

   return whitespace_string:sub(1, cut_pos)
end

local function regular_backspace(cursor_pos, current_line)
   local row = cursor_pos[1]
   local col = cursor_pos[2]

   local behind_cursor = current_line:sub(1, col)
   local after_cursor = current_line:sub(col + 1)

   if (row == 1) and (col == 0) then
      -- if first character first line, do nothing
      return

   elseif (col == 0) then
      -- if at start of the line, combine line with previous line
      local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
      local new_line = prev_line .. current_line
      vim.api.nvim_buf_set_lines(0, row - 2, row, false, {new_line})
      vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line})

   elseif contains_pair(cursor_pos, current_line) then
      remove_pair(cursor_pos, current_line)

   elseif contains_only_whitespace(behind_cursor) then
      local tabs_to_spaces_ratio = vim.api.nvim_get_option_value("tabstop", { buf = 0 })
      local trimmed_whitespace = trim_whitespace(behind_cursor, tabs_to_spaces_ratio)
      local trimmed_line = trimmed_whitespace .. after_cursor
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {trimmed_line})
      vim.api.nvim_win_set_cursor(0, {row, #trimmed_whitespace})

   else
      -- simply remove previous character (UTF-8 safe)
      local new_line, new_col = delete_char_before_cursor_utf8(current_line, col)
      if new_line then
         vim.api.nvim_buf_set_lines(0, row - 1, row, false, {new_line})
         vim.api.nvim_win_set_cursor(0, {row, new_col})
      end
   end
end

local function remove_whitespace(cursor_pos, current_line)
   local row = cursor_pos[1]
   local col = cursor_pos[2]
   local after_cursor = current_line:sub(col + 1)
   local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
   local prev_non_whitespace_line = ""
   local prev_line_index = 1
   local at_start_of_file = false

   -- find the previous non-whitespace lines indentation
   while true do
      prev_non_whitespace_line = vim.api.nvim_buf_get_lines(0, row - prev_line_index - 1, row - prev_line_index, false)[1]

      -- if you hit the start of the file, delete the whitespace behind the cursor
      if (prev_non_whitespace_line == nil) then
         at_start_of_file = true
         break
      end

      if not contains_only_whitespace(prev_non_whitespace_line) then
         break
      end

      prev_line_index = prev_line_index + 1
   end

   if (row == 1) then
      -- if on line 1, just delete from start to cursor
      vim.api.nvim_buf_set_lines(0, 0, 1, false, {after_cursor})
      vim.api.nvim_win_set_cursor(0, {1, 0})

   elseif at_start_of_file then
      -- if there is no previous non-whitespace line (at start of the file)
      if (count_whitepsace(current_line) > 0) then
         -- if the current line is indented, remove the current indentation
         vim.api.nvim_buf_set_lines(0, row - 1, row, false, {after_cursor})
         vim.api.nvim_win_set_cursor(0, {row, 0})

      else
         -- remove the line
         vim.api.nvim_buf_set_lines(0, row - 2, row, false, {after_cursor})
         vim.api.nvim_win_set_cursor(0, {row - 1, 0})
      end

   elseif (row > 1) and (count_whitepsace(current_line) > count_whitepsace(prev_non_whitespace_line)) and not contains_only_whitespace(current_line) then
      -- unindent to the above line's current indentation
      local prev_line_whitespace = prev_non_whitespace_line:match("^(%s+)") or ""
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {prev_line_whitespace .. after_cursor})
      vim.api.nvim_win_set_cursor(0, {row, #prev_line_whitespace})

   elseif (row > 1) and contains_only_whitespace(prev_line) then
      -- remove line above if empty
      vim.api.nvim_buf_set_lines(0, row - 2, row - 1, false, {})

   elseif (row > 1) then
      -- join the current line with the previous line
      local new_line = prev_line .. after_cursor
      vim.api.nvim_buf_set_lines(0, row - 2, row, false, {new_line}) -- replace both lines w new_line
      vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line}) -- set cursor at end of previous line content

   else
      -- should never be called, just a failsafe
      regular_backspace(cursor_pos, current_line)
   end
end

function M.smart_backspace()
   local current_line = vim.api.nvim_get_current_line()
   local cursor_pos = vim.api.nvim_win_get_cursor(0)
   local behind_cursor = current_line:sub(1, cursor_pos[2])

   if vim.g.smart_backspace_toggled == false then
      regular_backspace(cursor_pos, current_line)

   elseif contains_only_whitespace(behind_cursor) then
      remove_whitespace(cursor_pos, current_line)

   elseif contains_pair(cursor_pos, current_line) then
      remove_pair(cursor_pos, current_line)

   else
      remove_charater(cursor_pos, current_line)
   end
end

function M.regular_backspace()
   local current_line = vim.api.nvim_get_current_line()
   local cursor_pos = vim.api.nvim_win_get_cursor(0)
   regular_backspace(cursor_pos, current_line)
end

return M
