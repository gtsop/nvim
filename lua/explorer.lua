local M = {}

local state = require("state")

local explorer_window = nil
local explorer_group = nil

function M.show()
  if not explorer_window then
    M.open()
  else
    vim.api.nvim_set_current_win(explorer_window)
  end
end

function M.open()

  local project_dir = state.get_project_dir()

  vim.cmd("topleft 40vnew " .. project_dir)

  vim.api.nvim_buf_set_option(0, "filetype", "dir-view.explorer")
  vim.b.is_explorer = true

  explorer_window = vim.api.nvim_get_current_win()
  explorer_group = vim.api.nvim_create_augroup(("explorer_%d"):format(explorer_window), { clear = true })

  -- Abort explorer state when user edits a file
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = explorer_group,
    callback = convert_window_to_non_explorer
  })

  -- Setup Cleanup
  vim.api.nvim_create_autocmd("WinClosed", {
    group = explorer_group,
    pattern = tostring(explorer_window),
    once = true,
    callback = M.close
  })
end

function M.close()
  clear_window()
  clear_augroup()
end

function clear_window()
  if explorer_window then
    if vim.api.nvim_win_is_valid(explorer_window) then
      vim.api.nvim_win_close(explorer_window, true)
    end
    explorer_window = nil
  end
end

function clear_augroup()
  if explorer_group then
    pcall(vim.api.nvim_del_augroup_by_id, explorer_group)
    explorer_group = nil
  end
end

function convert_window_to_non_explorer()
  local win_id = vim.api.nvim_get_current_win()
  local filetype = vim.bo.filetype

  -- The window that was previously the explorer, no it is editing a file
  if win_id == explorer_window and filetype ~= "dir-view" then
    clear_augroup()
    vim.b.is_explorer = false
    explorer_window = nil
  end
end

vim.api.nvim_create_user_command("Explorer", M.show, { nargs = 0 })
vim.api.nvim_create_user_command("ExplorerShow", M.show, { nargs = 0 })
vim.api.nvim_create_user_command("ExplorerOpen", M.open, { nargs = 0 })
vim.api.nvim_create_user_command("ExplorerClose", M.close, { nargs = 0 })

return M
