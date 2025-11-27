local LinterView = {}
LinterView.__index = LinterView

function LinterView.new()
  local self = setmetatable({}, LinterView)

  function self.replace_lines(lines)
    local view = vim.fn.winsaveview()
    local buffer = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

    vim.fn.winrestview(view)
  end

  return self
end

return LinterView
