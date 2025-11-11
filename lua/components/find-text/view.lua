local M = {}
M.__index = {}

local Panel = require("utils.ui.panel")

function get_rendered_lines(model)
  local lines = {}
  local nodes = {}

  for _, entry in ipairs(model) do
    table.insert(nodes, entry)
    table.insert(nodes, entry)
    table.insert(lines, entry.file)
    table.insert(lines, tostring(entry.line) .. ":" .. entry.text)
  end

  return lines, nodes
end

function M.new()
  local self = setmetatable({}, M)

  local panel = Panel:new({ name = "seeker", position = "bottom" })

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buffer, "filetype", "seeker")
  vim.api.nvim_buf_set_option(buffer, "modifiable", false)

  local rendered_lines = nil
  local rendered_nodes = nil

  function self.show()
    panel:open({ buffer = buffer })
  end

  function self.render(model)
    rendered_lines, rendered_nodes = get_rendered_lines(model)

    vim.api.nvim_buf_set_option(buffer, "modifiable", true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, rendered_lines)
    vim.api.nvim_buf_set_option(buffer, "modifiable", false)
  end

  function self.close()
    panel:close()
  end

  function self.get_hovered_node()
    if not rendered_nodes then
      return nil
    end

    local line_number = vim.api.nvim_win_get_cursor(0)[1]

    return rendered_nodes[line_number]
  end

  function self.get_buffer()
    return buffer
  end

  return self
end

return M
