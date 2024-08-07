local M = {}

Utils = require('blink.indent.utils')

M.partial_draw = function(ns, line_indents, bufnr, start_line, end_line, left_offset)
  local shiftwidth = Utils.get_shiftwidth(bufnr)
  local symbol = '▎' .. string.rep(' ', shiftwidth - 1)

  -- add the new indents
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  local previous_indent_level = line_indents[start_line]
  for line_number = start_line, end_line do
    local line = lines[line_number - start_line + 1]
    local whitespace_chars = line:match('^%s*')

    local is_all_whitespace = #whitespace_chars == #line
    local current_indent_level = line_indents[line_number]
    local indent_level = (is_all_whitespace and previous_indent_level ~= nil) and previous_indent_level
      or current_indent_level
    previous_indent_level = indent_level

    -- draw
    if indent_level > 0 then
      local virt_text = string.rep(symbol, indent_level)

      local success, symbol_offset_index = pcall(vim.str_byteindex, symbol, left_offset)
      if not success then goto continue end
      virt_text = virt_text:sub(symbol_offset_index + 1)
      vim.api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, {
        virt_text = { { virt_text, 'BlinkIndent' } },
        virt_text_pos = 'overlay',
        hl_mode = 'combine',
        priority = 1,
      })
    end

    ::continue::
  end
end

return M
