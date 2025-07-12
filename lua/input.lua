local M = {}

local utils = require("utils")

local esc_code   = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
local cr_code    = vim.api.nvim_replace_termcodes("<CR>",  true, false, true)
local bs_code    = vim.api.nvim_replace_termcodes("<BS>",  true, false, true)

local input_on_key_ns = nil
local input_str = ""
local input_win = nil

function M.open(on_change, on_submit, on_cancel)
  if input_on_key_ns then
    return
  end

  vim.cmd('botright split')

  input_win = vim.api.nvim_get_current_win()
  input_buf = utils.create_scratch_buffer()

  vim.api.nvim_win_set_buf(0, input_buf)

  on_change(input_str)

  input_on_key_ns = vim.on_key(function(key, raw)
    if raw == cr_code then
      on_submit(input_str)
    elseif raw == esc_code then
      M.close()
    elseif raw == bs_code then
      if #input_str > 0 then
        input_str = input_str:sub(1, -2)
        on_change(input_str)
      end
    else
      input_str = input_str .. raw
      on_change(input_str)
    end

    return ""
  end, nil, { allow_mapping = false })
end

function M.close()
  if not input_on_key_ns then
    return
  end

  vim.on_key(nil, input_on_key_ns)

  input_on_key_ns = nil
  input_str = ""
  input_win = nil
  input_buf = nil
end

function M.print(lines)

  local last_row = #lines
  lines[last_row] = lines[last_row] .. " "

  local last_col = #lines[last_row]

  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(input_win, { last_row, last_col })
end

return M
