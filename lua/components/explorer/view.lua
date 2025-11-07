local M = {}
M.__index = M

local Panel = require("utils.ui.panel")

local function get_node_lines(tree, prefix)
  if not prefix then
    prefix = ""
  end

  local lines = {}
  local nodes = {}

  for _, node in ipairs(tree) do
    if node.is_dir then
      if node.tree then
        table.insert(lines, prefix .. "⮟ " .. node.name .. "/")
      else
        table.insert(lines, prefix .. "⮞ " .. node.name .. "/")
      end
      table.insert(nodes, node)
    else
      table.insert(lines, prefix .. "  " .. node.name)
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

function M.new(args)
  local self = setmetatable({}, M)

  if not args then
    args = {}
  end

  local panel = Panel:new({
    name = "explorer",
    on_enter = function()
      self.expand()
    end,
    on_leave = function()
      self.collapse()
    end,
    on_close = function()
      self.close()
    end,
  })

  local window_width = args.window_width or 40

  local rendered_nodes = nil
  local rendered_lines = nil

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buffer, "filetype", "explorer")
  vim.api.nvim_buf_set_option(buffer, "modifiable", false)

  function self.close()
    panel:close()
  end

  function self.render(model)
    rendered_lines, rendered_nodes = get_node_lines(model.tree)

    vim.api.nvim_buf_set_option(buffer, "modifiable", true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, rendered_lines)
    vim.api.nvim_buf_set_option(buffer, "modifiable", false)
  end

  function self.show()
    panel:open({ buffer = buffer })
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

  function self.hover_node(node)
    if not rendered_nodes then
      return nil
    end

    local nodeIndex = table.index_of(rendered_nodes, node)
    if nodeIndex then
      local window = panel:get_window()
      vim.api.nvim_set_current_win(window)
      vim.api.nvim_win_set_cursor(window, { nodeIndex, 1 })
    else
      vim.print("Unable to find node")
    end
  end

  function self.expand()
    -- resize window to fit all contents
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

    if not lines then
      return
    end

    local max_length = window_width
    for _, line in ipairs(lines) do
      if #line > max_length then
        max_length = #line
      end
    end
    panel:set_width(max_length)
  end

  function self.collapse()
    panel:set_width(window_width)
  end

  return self
end

return M
