local M = {}

function M.new(_, view, controller)
  local self = setmetatable({}, M)

  function self.create_file()
    controller.using_hovered_node(function(node)
      controller:service('ide').create_file(node.path, controller.refresh)
    end)
  end

  vim.keymap.set('n', 'a', self.create_file, { buffer = view.get_buffer() })

  return self
end

return M
