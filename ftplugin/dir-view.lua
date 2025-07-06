if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

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
  if vim.w.dir_view_initial_path then
    vim.cmd("edit " .. vim.w.dir_view_initial_path)
  end
end, { buffer = true, silent = true, noremap = true})
