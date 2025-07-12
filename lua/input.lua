local M = {}

local utils = require("utils")

local esc_code   = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
local cr_code    = vim.api.nvim_replace_termcodes("<CR>",  true, false, true)
local bs_code    = vim.api.nvim_replace_termcodes("<BS>",  true, false, true)
local up_code    = vim.api.nvim_replace_termcodes("<Up>",   true, false, true)
local down_code  = vim.api.nvim_replace_termcodes("<Down>", true, false, true)

local input_on_key_ns = nil
local input_str = ""
local input_win = nil
local input_options = nil
local input_selected_option = 1

function M.open(on_change, on_submit, on_cancel)
  if input_on_key_ns then
    return
  end

  vim.cmd('botright split')

  input_win = vim.api.nvim_get_current_win()
  input_buf = utils.create_scratch_buffer()

  vim.api.nvim_win_set_buf(input_win, input_buf)
  vim.api.nvim_win_set_option(input_win, "number", false)
  vim.api.nvim_win_set_option(input_win, "relativenumber", false)

  on_change(input_str)

  input_on_key_ns = vim.on_key(function(key, raw)
    if raw == cr_code then
      if input_options then
        on_submit(input_options[input_selected_option])
      else
        on_submit(input_str)
      end
    elseif raw == esc_code then
      M.close()
    elseif raw == bs_code then
      if #input_str > 0 then
        input_str = input_str:sub(1, -2)
        on_change(input_str)
      end
    elseif raw == down_code then
      if input_selected_option > 1 then
        input_selected_option = input_selected_option - 1
        M.print()
      end
    elseif raw == up_code then
      if input_selected_option < #input_options then
        input_selected_option = input_selected_option + 1
        M.print()
      end
    else
      input_str = input_str .. raw
      on_change(input_str)
    end

    return ""
  end, nil, { allow_mapping = false })
end

function M.print()

  local lines = {}

  if input_options then
    for i, option in ipairs(input_options) do
      if i == input_selected_option then
        table.insert(lines, " ~ " .. option .. " ~")
      else
        table.insert(lines, "   " .. option)
      end
    end
    lines = vim.fn.reverse(lines)
  end

  local win_width = vim.api.nvim_win_get_width(input_win)
  table.insert(lines, string.rep("_", win_width))

  table.insert(lines, ">>> " .. input_str) 

  local last_row = #lines
  lines[last_row] = lines[last_row] .. " "

  local last_col = #lines[last_row]

  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, lines)
  vim.api.nvim_win_set_height(input_win, #lines)
  vim.api.nvim_win_set_cursor(input_win, { last_row, last_col })
end

function M.options(options)
  input_options = options
end

function M.close()
  if not input_on_key_ns then
    return
  end

  vim.api.nvim_win_close(0, true)
  vim.on_key(nil, input_on_key_ns)

  input_on_key_ns = nil
  input_str = ""
  input_win = nil
  input_buf = nil
  input_options = nil
  input_selected_option = 1
end

return M
