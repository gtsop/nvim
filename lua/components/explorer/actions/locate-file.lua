local M = {}

function M.new(model, view, controller)
  local self = setmetatable({}, M)

  local function locate_file()
      local file = vim.api.nvim_buf_get_name(0)
      local node = model.expand_until_path(file)
      controller.render()
      view.hover_node(node)
  end

  vim.keymap.set('n', 'gte', locate_file)

  return self
end

return M
