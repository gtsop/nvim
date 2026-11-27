local M = {}

function M.save_layout()
  local wins = vim.api.nvim_list_wins()
  local saved = {}

  for _, wid in ipairs(wins) do
    saved[wid] = {
      width = vim.api.nvim_win_get_width(wid),
      height = vim.api.nvim_win_get_height(wid),
    }
  end

  return saved
end

function M.restore_layout(saved)
  if not saved then
    return
  end

  local wins = vim.api.nvim_list_wins()

  for _, wid in ipairs(wins) do
    local s = saved[wid]
    if s then
      vim.api.nvim_win_set_width(wid, s.width)
      vim.api.nvim_win_set_height(wid, s.height)
    end
  end
end

return M
