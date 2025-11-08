local M = {}
M.__index = M

local Model = require("components.seeker.model")
local View = require("components.seeker.view")

function M.new(opts)
  local self = setmetatable({ di = { providers = {}, instances = {} } }, M)

  local model = Model.new({ root_dir = opts.base_path })
  local view = View.new()
  local view_buffer = view.get_buffer()

  function self.seek(cargs)
    model.search(cargs.args, function(results)
      view.render(results)
      view.show()
    end)
  end

  function self.show()
    view.show()
  end

  function self.using_hovered_node(callback)
    local node = view.get_hovered_node()
    if not node then
      vim.print("explorer: failed to parse selected node")
      return
    end
    callback(node)
  end

  function self.enter_node()
    self.using_hovered_node(function(node)
      self:service("ide").edit(node.file)
    end)
  end

  function self.close()
    view.close()
  end

  vim.api.nvim_create_user_command("SeekerFind", self.seek, { nargs = 1 })

  vim.keymap.set("n", "<CR>", self.enter_node, { buffer = view_buffer })
  vim.keymap.set("n", "<esc>", self.close, { buffer = view_buffer })

  return self
end

function M:register(name, provider)
  self.di.providers[name] = provider
end

function M:service(name)
  if not self.di.instances[name] then
    self.di.instances[name] = self.di.providers[name](self)
  end
  return self.di.instances[name]
end

return M
