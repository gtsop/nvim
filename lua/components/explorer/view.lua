local M = {}
M.__index = M

function M.new(buffer)
  local self = setmetatable({}, M)

  function self.render(tree)
    local lines = {}

    for _, node in ipairs(tree) do
      if node.is_dir then
        table.insert(lines, node.name .. "/")
      else
        table.insert(lines, node.name)
      end
    end

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  end

  return self
end

return M
