local M = {}

local utils = require("utils")
local explorer = require("explorer")

local function get_dir_edit_window()

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

local function get_file_edit_window()
  local avoid_filetypes = { "dir-view", "dir-view.explorer", "explorer" }

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not table.contains(avoid_filetypes, utils.win_get_buf_filetype(win)) then
      return win
    end
  end

  return vim.api.nvim_get_current_win()
end

local function split_path(full_path)
  local dir, file = full_path:match("^(.*[/\\])([^/\\]+)$")
  dir  = dir  or ""
  file = file or full_path

  local base, ext = file:match("^(.*)%.([^%.]+)$")
  if not base then
    base, ext = file, ""
  end

  return dir, base, ext
end

local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close(); return true end
  return false
end

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

function M.create_file(path, callback)
  local dir = vim.fs.dirname(path)

  vim.ui.input({ prompt = "New file: ", default = dir .. "/" }, function(new_file)
    if new_file then
      vim.fn.mkdir(vim.fs.dirname(new_file), "p")
      vim.fn.writefile({}, new_file)
      if callback then
        callback()
      end
    end
  end)
end

function M.delete_file(path, callback)
  vim.ui.input({ prompt = "Are you sure you want to delete '" .. path .. "' ? [y/n]: " }, function(answer)
    if answer == "y" then
      vim.fn.delete(path)
      if callback then
        callback()
      end
    end
  end)
end

function M.move_file(path, callback)
  vim.ui.input({ prompt = "Give new file location for", default = path }, function(new_file)
    if new_file then
      vim.fn.rename(path, new_file)
      if callback then
        callback()
      end
    end
  end)
end

M.from_code_to_test = function(full_path)
  local dir, base, ext = split_path(full_path)

  local test_path = dir .. "/" .. base .. ".test." .. ext

  if file_exists(test_path) then
    M.edit(test_path)
  else
    vim.print("Test file: " .. test_path .. " does not exist")
  end
end

M.from_test_to_code = function(full_path)
  local dir, base, ext = split_path(full_path)

  local code_path = dir .. "/" .. base:gsub("%.test", "") .. "." .. ext

  if file_exists(code_path) then
    M.edit(code_path)
  else
    vim.print("Test file: " .. code_path .. " does not exist")
  end
end


return M
