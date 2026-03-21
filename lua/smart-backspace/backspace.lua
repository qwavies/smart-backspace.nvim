local M = {}

---UTF-8 safe helper function to find the character before cursor
---@param cursor_pos table positions: [1] = row (int), [2] = col (int)
---@param current_line string contents of current line
---@return integer prev_char_byte_idx previous character utf8 index
local function find_char_before_cursor_utf8(cursor_pos, current_line)
  local col = cursor_pos[2]

  -- Convert byte index (0-indexed) to character index
  local char_idx = vim.str_utfindex(current_line, "utf-32", col)

  -- Get byte index of the previous character
  local prev_char_byte_idx = vim.str_byteindex(current_line, "utf-32", char_idx - 1)

  return prev_char_byte_idx
end

---Checks if the current selected character and the character after is a pair. Eg: "()" or "{}"
---@param cursor_pos table positions: [1] = row (int), [2] = col (int)
---@param current_line string contents of current line
---@return boolean
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
    if (current_character == pair[1]) and (next_character == pair[2]) then
      return true
    end
  end
  return false
end

---Checks if a given char is the first part of a pair. Eg: "(" or "{"
---@param char string the character to check
---@return boolean
local function is_opening_pair(char)
  local code_pairs = {
    "(",
    "[",
    "{",
    "<",
  }

  for _, opening_pair in ipairs(code_pairs) do
    if (char == opening_pair) then
      return true
    end
  end

  return false
end

---Removes the current and next character.
---Use to remove certain pairs. eg: "()" or "{}"
---@param cursor_pos table positions: [1] = row (int), [2] = col (int)
local function remove_pair(cursor_pos)
  local row = cursor_pos[1]
  local col = cursor_pos[2]
  vim.api.nvim_buf_set_text(0, row - 1, col - 1, row - 1, col + 1, {""})
  vim.api.nvim_win_set_cursor(0, {row, col - 1})
end

---Removes the currently selected character or join current line with previous line
---@param cursor_pos table positions: [1] = row (int), [2] = col (int)
---@param current_line string contents of current line current line with previous line
local function remove_character(cursor_pos, current_line)
  local row = cursor_pos[1]
  local col = cursor_pos[2]

  if (col > 0) then
    -- delete character before cursor (UTF-8 safe)
    local new_col = find_char_before_cursor_utf8(cursor_pos, current_line)
    vim.api.nvim_buf_set_text(0, row - 1, new_col, row - 1, col, {""})
    vim.api.nvim_win_set_cursor(0, {row, new_col})

  elseif (row > 1) then
    -- at start of line, join with previous line
    local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
    vim.api.nvim_buf_set_text(0, row - 2, #prev_line, row - 1, 0, {""})
    vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line})
  end
  -- edge case: on line 1 first character, do nothing
end

---Checks is a given string only contains whitespace (spaces, tabs)
---@param str string the string to check
---@return boolean
local function contains_only_whitespace(str)
  return not str:find("%S")
end

---Counts the amount of leading whitespace within a given string.
---@param str string the given string
---@return integer whitespace_count total amount of leading whitespace. Spaces += 1, tabs += nvim's "tabstop"
local function count_leading_whitespace(str)
  local tabs_to_spaces_ratio = vim.api.nvim_get_option_value("tabstop", { buf = 0 })
  local whitespace_count = 0

  for char in str:gmatch(".") do
    if char == " " then
      whitespace_count = whitespace_count + 1
    elseif char == "\t" then
      whitespace_count = whitespace_count + tabs_to_spaces_ratio
    else
      -- non-whitespace character
      return whitespace_count
    end
  end

  return whitespace_count
end

---Calculates the value of whitespace in `whitespace_string` and rounds it down to the nearest multiple of `tab_width`
---eg: trim_whitespace(string.rep(" ", 6), 3) -> "   "
---eg: trim_whitespace(string.rep(" ", 5), 3) -> "   "
---eg: trim_whitespace(string.rep(" ", 3), 3) -> ""
---@param whitespace_string string a string containing only whitespace
---@param tab_width integer the amount of indentation a tab is worth. Usually use vim.bo.tabstop
---@return string trimmed_whitespace a trimmed version of `whitespace_string`
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

--Checks if the previous and next non-whitespace characters are a pair of brackets
---@param prev_line string|nil contents of the previous line (nil if no previous line)
---@param current_line string contents of current line
---@param next_line string|nil contents of the next line (nil if no next line)
---@return boolean
local function within_empty_brackets(prev_line, current_line, next_line)
  if (prev_line == nil) or (next_line == nil) then
    return false
  end

  local prev_line_last_char = prev_line:match("(%S)%s*$")
  local next_line_first_char = next_line:match("^%s*(%S)")

  local code_pairs = {
    { "(", ")" },
    { "[", "]" },
    { "{", "}" },
    { "<", ">" },
  }

  for _, pair in pairs(code_pairs) do
    if contains_only_whitespace(current_line) and (prev_line_last_char == pair[1]) and (next_line_first_char == pair[2]) then
      return true
    end
  end

  return false
end

---Emulates the default neovim backspace
---@param cursor_pos table positions: [1] = row (int), [2] = col (int)
---@param current_line string contents of current line
local function regular_backspace(cursor_pos, current_line)
  local row = cursor_pos[1]
  local col = cursor_pos[2]

  local behind_cursor = current_line:sub(1, col)

  if (row == 1) and (col == 0) then
    -- if first character first line, do nothing
    return

  elseif (col == 0) then
    -- if at start of the line, combine line with previous line
    local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
    vim.api.nvim_buf_set_text(0, row - 2, #prev_line, row - 1, 0, {""})
    vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line})

  elseif contains_pair(cursor_pos, current_line) then
    remove_pair(cursor_pos)

  elseif contains_only_whitespace(behind_cursor) then
    local indentation_level = vim.bo.shiftwidth
    local trimmed_whitespace = trim_whitespace(behind_cursor, indentation_level)
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, col, {trimmed_whitespace})
    vim.api.nvim_win_set_cursor(0, {row, #trimmed_whitespace})

  else
    -- simply remove previous character (UTF-8 safe)
    local new_col = find_char_before_cursor_utf8(cursor_pos, current_line)
    vim.api.nvim_buf_set_text(0, row - 1, new_col, row - 1, col, {""})
    vim.api.nvim_win_set_cursor(0, {row, new_col})
  end
end

---Removes all indentation from behind the cursor
---@param cursor_pos table positions: [1] = row (int), [2] = col (int)
---@param current_line string contents of current line
local function remove_whitespace(cursor_pos, current_line)
  local row = cursor_pos[1]
  local col = cursor_pos[2]
  local next_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
  local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
  local prev_non_whitespace_line = ""

  local prev_line_index = 1
  local at_start_of_file = false

  -- find the previous non-whitespace lines indentation
  while (not at_start_of_file) and (contains_only_whitespace(prev_non_whitespace_line)) do
    prev_non_whitespace_line = vim.api.nvim_buf_get_lines(0, row - prev_line_index - 1, row - prev_line_index, false)[1]

    -- if you hit the start of the file, set a flag to delete the whitespace behind the cursor
    if (prev_non_whitespace_line == nil) then
      at_start_of_file = true
      break
    end

    prev_line_index = prev_line_index + 1
  end

  if (row == 1) then
    -- if on line 1, just delete from start to cursor
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, col, {""})
    vim.api.nvim_win_set_cursor(0, {1, 0})

  elseif at_start_of_file then
    -- if there is no previous non-whitespace line (at start of the file)
    if (count_leading_whitespace(current_line) > 0) then
      -- if the current line is indented, remove the current indentation
      vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, col, {""})
      vim.api.nvim_win_set_cursor(0, {row, 0})

    else
      -- remove the line
      vim.api.nvim_buf_set_text(0, row - 2, 0, row - 1, 0, {""})
      vim.api.nvim_win_set_cursor(0, {row - 1, 0})
    end

  elseif within_empty_brackets(prev_line, current_line, next_line) then
    vim.api.nvim_buf_set_text(0, row - 2, #prev_line, row, (next_line:find("%S") or 1) - 1, {""})
    vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line:gsub("%s+$", "")})

  elseif is_opening_pair(prev_non_whitespace_line:match("(%S)%s*$")) or (current_line:match("%S") == ".") then
    -- sees if above line ends in a opeing pair of brackets OR current line starts with a "."

    local prev_line_whitespace_level = count_leading_whitespace(prev_non_whitespace_line)
    local current_line_whitespace_level = count_leading_whitespace(current_line)
    local single_indentation_level = vim.bo.shiftwidth
    local correct_indentation_level = prev_line_whitespace_level + single_indentation_level

    if (current_line_whitespace_level > correct_indentation_level) then
      -- if over-indented, set to correct indentation
      local prev_line_whitespace = prev_non_whitespace_line:match("^(%s+)") or ""
      -- WARN: only ever adds spaces. Maybe allow to change to tabs in config?
      local correct_indentation = prev_line_whitespace .. string.rep(" ", single_indentation_level)
      vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, col, {correct_indentation})
      vim.api.nvim_win_set_cursor(0, {row, #correct_indentation})

    elseif contains_only_whitespace(prev_line) then
      vim.api.nvim_buf_set_text(0, row - 2, 0, row - 1, 0, {""})
      vim.api.nvim_win_set_cursor(0, {row - 1, col})

    else
      -- otherwise, join the current line with the previous line
      vim.api.nvim_buf_set_text(0, row - 2, #prev_line, row - 1, (current_line:find("%S") or #current_line + 1) - 1, {""})
      vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line}) -- set cursor at end of previous line content
    end

  elseif (count_leading_whitespace(current_line) > count_leading_whitespace(prev_non_whitespace_line)) then
    -- unindent to the above (non-whitespace) line's current indentation
    local prev_line_whitespace = prev_non_whitespace_line:match("^(%s+)") or ""
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, (current_line:find("%S") or #current_line + 1) - 1, {prev_line_whitespace})
    vim.api.nvim_win_set_cursor(0, {row, #prev_line_whitespace})

  elseif contains_only_whitespace(prev_line) then
    -- remove line above if empty
    vim.api.nvim_buf_set_text(0, row - 2, #prev_line, row - 1, 0, {""})
    vim.api.nvim_win_set_cursor(0, {row - 1, col})

  else
    -- join the current line with the previous line
    vim.api.nvim_buf_set_text(0, row - 2, #prev_line, row - 1, (current_line:find("%S") or #current_line + 1) - 1, {""})
    vim.api.nvim_win_set_cursor(0, {row - 1, #prev_line}) -- set cursor at end of previous line content
  end
end

---Smart backspace. Optimise whitespace deletions for coding and intelligently removing indentation
function M.smart_backspace()
  local current_line = vim.api.nvim_get_current_line()

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local behind_cursor = current_line:sub(1, cursor_pos[2])

  if (vim.g.smart_backspace_enabled == false) or (vim.g.smart_backspace_toggled == false) then
    regular_backspace(cursor_pos, current_line)

  elseif contains_only_whitespace(behind_cursor) then
    -- if the cursor is in the middle of the whitespace indentation,
    -- use the logic of the cursor being at the first non-whitespace character
    local first_non_ws = current_line:find("%S")
    local col = first_non_ws and (first_non_ws - 1) or #current_line
    cursor_pos = { cursor_pos[1], col } -- replaces the column with first non-whitespace char
    remove_whitespace(cursor_pos, current_line)

  elseif contains_pair(cursor_pos, current_line) then
    remove_pair(cursor_pos)

  else
    remove_character(cursor_pos, current_line)
  end
end

---Emulates the default neovim backspace
function M.regular_backspace()
  local current_line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  regular_backspace(cursor_pos, current_line)
end

return M
