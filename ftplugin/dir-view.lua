if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

local state = require("state")
local utils = require("utils")

-- Press "Enter" to edit the file under cursor
vim.keymap.set("n", "<CR>", function()
  local path = vim.api.nvim_buf_get_name(0)
  local filename = vim.api.nvim_get_current_line()

  local full_path = vim.fs.normalize(path .. "/" .. filename)

  if utils.is_dir(full_path) then
    vim.cmd("edit " .. full_path)
  else
    local next_win = utils.get_next_win()
    local buff_id = vim.fn.bufadd(full_path)

    vim.api.nvim_win_set_buf(next_win, buff_id)
    vim.api.nvim_set_current_win(next_win)
  end
end, { buffer = true, silent = true, noremap = true })

-- Press "-" to go to parent directory
vim.keymap.set("n", "-", function()
  local path = vim.api.nvim_buf_get_name(0)
  local parent = vim.fs.dirname(path)
  vim.cmd("edit " .. parent)
end, { buffer = true, silent = true, noremap = true})
  
-- Press "0" to go to the initial directory being edited
vim.keymap.set("n", "0", function() 
  local project_dir = state.get_project_dir()
  vim.cmd("edit " .. project_dir)
end, { buffer = true, silent = true, noremap = true})
