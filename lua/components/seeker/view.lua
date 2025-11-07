local M = {}
M.__index = {}

function get_rendered_lines(model)
  local lines = {}

  for _, entry in ipairs(model) do
    table.insert(lines, entry.file)
    table.insert(lines, tostring(entry.line) .. ":" .. entry.text)
  end

  return lines
end

function M.new()
  local self = setmetatable({}, M)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buffer, "filetype", "seeker")
  vim.api.nvim_buf_set_option(buffer, "modifiable", false)

  function self.render(model)
    local rendered_lines = get_rendered_lines(model)

    vim.api.nvim_buf_set_option(buffer, "modifiable", true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, rendered_lines)
    vim.api.nvim_buf_set_option(buffer, "modifiable", false)
  end

  return self
end

return M
