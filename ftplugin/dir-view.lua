if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

local state = require("state")

-- Press "Enter" to edit the file under cursor
vim.keymap.set("n", "<CR>", function()
  local path = vim.api.nvim_buf_get_name(0)
  local filename = vim.api.nvim_get_current_line()
  vim.cmd("edit " .. path .. "/" .. filename)
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
