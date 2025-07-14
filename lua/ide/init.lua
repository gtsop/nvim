local M = {}

local utils = require("utils")
local explorer = require("explorer")

M.edit = function(full_path)

  local buff_id = vim.fn.bufadd(full_path)
  local win_id = nil

  if utils.is_dir(full_path) then
    win_id = get_dir_edit_window()
  else
    win_id = get_file_edit_window()
  end

  vim.api.nvim_win_set_buf(win_id, buff_id)
  vim.api.nvim_set_current_win(win_id)
end

function get_dir_edit_window()

  local explorer_win_id = explorer.get_window()

  if explorer_win_id then
    return explorer_win_id
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if utils.win_get_buf_filetype(win) == "dir-view" then
      return win
    end
  end

  return vim.api.nvim_get_current_win()
end

function get_file_edit_window()
  local avoid_filetypes = { "dir-view", "dir-view.explorer" }

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not table.contains(avoid_filetypes, utils.win_get_buf_filetype(win)) then
      return win
    end
  end

  return vim.api.nvim_get_current_win()
end

return M
