vim.api.nvim_create_user_command("ExplorerOpen", function()
  local path = vim.api.nvim_buf_get_name(0)
  local parent = vim.fs.dirname(path)
  vim.cmd("topleft vnew " .. parent)
  vim.w.is_explorer = true
end, { nargs = 0 })

vim.api.nvim_create_user_command("ExplorerShow", function()
  local explorer_win;
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ok, is_explorer = pcall(vim.api.nvim_win_get_var, win, 'is_explorer')
    if ok then
      if is_explorer then
        explorer_win = win
        break
      end
    end
  end

  if explorer_win then
    vim.api.nvim_set_current_win(explorer_win)
  else
    vim.cmd("ExplorerOpen")
  end
end, { nargs = 0 })
