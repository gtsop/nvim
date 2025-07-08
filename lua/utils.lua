local M = {}

function M.is_dir(path)
  local file = vim.uv.fs_stat(vim.fs.normalize(path))

  return file and file.type == "directory"
end

function M.get_next_win()
  local current_win = vim.api.nvim_get_current_win()

  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins == 1 then
    return current_win
  end

  for i, win in ipairs(wins) do
    if win == current_win then
      -- Black mathic
      return wins[i % #wins + 1]
    end
  end
end

return M
