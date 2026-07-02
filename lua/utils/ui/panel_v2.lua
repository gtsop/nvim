local Panel = {}
Panel.__index = Panel

function Panel:new(args)
  local this = setmetatable({
    apps = {},
    active_app = nil,
  }, Panel)

  if not args then
    args = {}
  end

  if args.position == "bottom" then
    vim.cmd("botright split")
  elseif args.position == "left" then
    vim.cmd("vsplit")
  end

  this.window = vim.api.nvim_get_current_win()
  vim.api.nvim_set_option_value("number", false, { win = this.window })
  vim.api.nvim_set_option_value("relativenumber", false, { win = this.window })
  vim.api.nvim_set_option_value("wrap", false, { win = this.window })
  this.group = vim.api.nvim_create_augroup((args.name .. "_%d"):format(this.window), { clear = true })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = this.group,
    callback = function()
      this:win_enter()
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = this.group,
    callback = function()
      this:win_leave()
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = this.group,
    callback = function(opts)
      this:win_closed(opts)
    end,
  })

  return setmetatable(this, Panel)
end

function Panel:register(name, args)
  self.apps[name] = args

  if not self.active_app then
    self.active_app = name
    self:open(name)
  end
end

function Panel:open(app_name)
  self.active_app = app_name
  if self.apps[app_name] then
    local buffer = self.apps[app_name].buffer
    vim.api.nvim_win_set_buf(self.window, buffer)
    vim.api.nvim_set_current_win(self.window)
    self:win_enter()
  end
end

function Panel:close()
  if self.window then
    if vim.api.nvim_win_is_valid(self.window) then
      vim.api.nvim_win_close(self.window, true)
    end
    self.window = nil
  end
  if self.group then
    pcall(vim.api.nvim_del_augroup_by_id, self.group)
    self.group = nil
  end
end

function Panel:win_enter()
  if vim.api.nvim_get_current_win() == self.window then
    if self.apps[self.active_app].on_enter then
      self.apps[self.active_app].on_enter()
    end
  end
end

function Panel:win_leave()
  if vim.api.nvim_get_current_win() == self.window then
    if self.apps[self.active_app].on_leave then
      self.apps[self.active_app].on_leave()
    end
  end
end

function Panel:win_closed(args)
  local event_win = tonumber(args.match)
  if event_win == self.window then
    if self.apps[self.active_app].on_close then
      self.apps[self.active_app].on_close()
    end
  end
end

function Panel:get_window()
  return self.window
end

function Panel:set_width(width)
  if not self.window then
    return
  end
  vim.api.nvim_win_set_width(self.window, width)
end

return Panel
