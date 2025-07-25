local M = {}
M.__index = M

function M.new()
  local self = setmetatable({}, M)

  local buffer = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_option(buffer, 'filetype', 'explorer')
  local window = nil

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

  function self.show()
    window = vim.api.nvim_open_win(buffer, true, {
      relative = '',
      split = 'left',
      width = 40
    })
    vim.api.nvim_win_set_var(window, 'is_explorer', true)
  end

  function self.get_window()
    return window
  end

  function self.get_buffer()
    return buffer
  end

  function self.get_hovered_node(tree)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    return tree[line]
  end

  return self
end

return M
