local M = {}
M.__index = M

function M.new(opts)
  local self = setmetatable({ di = { providers = {}, instances = {} } }, M)

  local model = require("components.explorer.model").new(opts.base_path)
  local view = require("components.explorer.view").new({
    window_width = opts.window_width,
  })

  local view_buffer = view.get_buffer()

  function self.render()
    local tree = model.get_tree()
    view.render(tree)
    view.expand()
  end

  function self.show()
    view.show()
  end

  function self.close()
    view.close()
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
      if node.is_dir then
        self.toggle_dir()
      else
        self.edit_file()
      end
    end)
  end

  -- Register actions
  self.copy_file = require("components.explorer.actions.copy-file").create(model, view, self)
  self.create_file = require("components.explorer.actions.create-file").create(model, view, self)
  self.delete_file = require("components.explorer.actions.delete-file").create(model, view, self)
  self.edit_file = require("components.explorer.actions.edit-file").create(model, view, self)
  self.find_file = require("components.explorer.actions.find-file").create(model, view, self)
  self.move_file = require("components.explorer.actions.move-file").create(model, view, self)
  self.refresh_dir = require("components.explorer.actions.refresh-dir").create(model, view, self)
  self.toggle_dir = require("components.explorer.actions.toggle-dir").create(model, view, self)

  -- Register keymaps
  vim.keymap.set("n", "<CR>", self.enter_node, { buffer = view_buffer })
  vim.keymap.set("n", "c", self.copy_file, { buffer = view_buffer })
  vim.keymap.set("n", "a", self.create_file, { buffer = view_buffer })
  vim.keymap.set("n", "d", self.delete_file, { buffer = view_buffer })
  vim.keymap.set("n", "m", self.move_file, { buffer = view_buffer })
  vim.keymap.set("n", "r", self.refresh_dir, { buffer = view_buffer })

  -- Register commands
  vim.api.nvim_create_user_command("ExplorerFindFile", self.find_file, { nargs = 0 })
  vim.api.nvim_create_user_command("ExplorerShow", self.show, { nargs = 0 })

  self.render()

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
