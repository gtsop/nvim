local M = {}
M.__index = M

function M.new(opts)
  local self = setmetatable({ di = { providers = {}, instances = {} }}, M)

  local model = require("components.explorer.model").new(opts.base_path)
  local view = require("components.explorer.view").new()

  local group = nil
  local window = nil

  function self.render()
    local tree = model.get_tree()
    view.render(tree)
  end

  function self.show()
    if window then
      vim.api.nvim_set_current_win(window)
      return
    end

    view.show()

    window = view.get_window()

    group = vim.api.nvim_create_augroup(("explorer_%d"):format(window), { clear = true })

    vim.api.nvim_create_autocmd("WinClosed", {
      group = group,
      pattern = tostring(window),
      once = true,
      callback = self.close
    })
  end

  function self.close()
    if window then
      if vim.api.nvim_win_is_valid(window) then
        vim.api.nvim_win_close(window, true)
      end
      window= nil
    end
    if group then
      pcall(vim.api.nvim_del_augroup_by_id, group)
      group = nil
    end
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
  require("components.explorer.actions.create-file").new(model, view, self)
  require("components.explorer.actions.delete-file").new(model, view, self)
  require("components.explorer.actions.edit-file").new(model, view, self)
  require("components.explorer.actions.locate-file").new(model, view, self)
  require("components.explorer.actions.move-file").new(model, view, self)
  require("components.explorer.actions.refresh-dir").new(model, view, self)
  require("components.explorer.actions.toggle-dir").new(model, view, self)

  -- Register keymaps
  local view_buffer = view.get_buffer()
  vim.keymap.set('n', '<CR>', self.enter_node,  { buffer = view_buffer })
  vim.keymap.set('n', 'a',    self.create_file, { buffer = view_buffer })
  vim.keymap.set('n', 'd',    self.delete_file, { buffer = view_buffer })
  vim.keymap.set('n', 'm',    self.move_file,   { buffer = view_buffer })
  vim.keymap.set('n', 'r',    self.refresh,     { buffer = view_buffer })
  vim.keymap.set('n', 'gte',  self.locate_file)

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
