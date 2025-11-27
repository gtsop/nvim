local LinterModel = {}
LinterModel.__index = LinterModel

function LinterModel.new()
  local self = setmetatable({}, LinterModel)

  function self.get_lines()
    local buffer = vim.api.nvim_get_current_buf()

    return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  end

  function self.get_file_path()
    local buffer = vim.api.nvim_get_current_buf()

    return vim.api.nvim_buf_get_name(buffer)
  end

  return self
end

return LinterModel
