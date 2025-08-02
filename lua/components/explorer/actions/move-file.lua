local M = {}

function M.new(_, view, controller)
  local self = setmetatable({}, M)

  local function move_file()
    controller.using_hovered_node(function(node)
      controller:service('ide').move_file(node.path, controller.refresh)
    end)
  end

  vim.keymap.set('n', 'd', move_file, { buffer = view.get_buffer() })

  return self
end

return M
