local M = {}
M.__index = M

local function find_node_by_path(tree, path)
  for _, node in ipairs(tree) do
    if node.path == path then
      return node
    end
    if node.tree then
      local child_node = find_node_by_path(node.tree, path)
      if child_node then
        return child_node
      end
    end
  end

  return nil
end

local function get_node_lines(tree, prefix)

  if not prefix then
    prefix = ""
  end

  local lines = {}
  local nodes = {}

  for _, node in ipairs(tree) do
    if node.is_dir then
      table.insert(lines, prefix .. node.name .. "/")
      table.insert(nodes, node)
    else
      table.insert(lines, prefix .. node.name)
      table.insert(nodes, node)
    end

    if node.tree then
      local c_lines, c_nodes = get_node_lines(node.tree, prefix .. "  ")
      table.extend(lines, c_lines)
      table.extend(nodes, c_nodes)
    end
  end

  return lines, nodes
end

function M.new()

  local self = setmetatable({}, M)

  local rendered_nodes = nil
  local rendered_lines = nil

  local buffer = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_option(buffer, 'filetype', 'explorer')
  local window = nil

  function self.render(tree)
    rendered_lines, rendered_nodes = get_node_lines(tree)

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, rendered_lines)
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

  function self.get_hovered_node()
    if not rendered_nodes then
      return nil
    end

    local line_number = vim.api.nvim_win_get_cursor(0)[1]

    return rendered_nodes[line_number]
  end

  return self
end

return M
