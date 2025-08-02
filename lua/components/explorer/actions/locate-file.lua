local M = {}

function M.new(m, v, c)
  local self = setmetatable({}, M)

  function c.locate_file()
      local file = vim.api.nvim_buf_get_name(0)
      local node = m.expand_until_path(file)
      c.render()
      v.hover_node(node)
  end

  return self
end

return M
