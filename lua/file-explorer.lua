local state = require("state")

local explorer_window = nil
local explorer_group = nil

function is_explorer_out_of_dir_view()
  local win_id = vim.api.nvim_get_current_win()
  local filetype = vim.bo.filetype

  return win_id == explorer_window and filetype ~= "dir-view" 
end

function clean_up_explorer_state()
  vim.api.nvim_del_augroup_by_id(explorer_group)
  explorer_window = nil
  explorer_group = nil
end

vim.api.nvim_create_user_command("ExplorerOpen", function()

  local project_dir = state.get_project_dir()

  vim.cmd("topleft 40vnew " .. project_dir)

  explorer_window = vim.api.nvim_get_current_win()
  explorer_group = vim.api.nvim_create_augroup(("explorer_%d"):format(explorer_window), { clear = true })

  -- Abort explorer state when user edits a file
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = explorer_group,
    callback = function(args)
      if is_explorer_out_of_dir_view() then
          clean_up_explorer_state()
      end
    end
  })

  -- Cleanup
  vim.api.nvim_create_autocmd("WinClosed", {
    group = explorer_group,
    pattern = tostring(explorer_window),
    once = true,
    callback = clean_up_explorer_state
  })
end, { nargs = 0 })

vim.api.nvim_create_user_command("ExplorerShow", function()
  if explorer_window then
    vim.api.nvim_set_current_win(explorer_window)
  else
    vim.cmd("ExplorerOpen")
  end
end, { nargs = 0 })

vim.api.nvim_create_user_command("ExplorerLocate", function()
  if explorer_window then
    vim.print(explorer_window)
  else
    vim.print("no explorer")
  end
end, { nargs = 0 })

