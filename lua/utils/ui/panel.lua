local Panel = {}
Panel.__index = Panel

function Panel:new(args)
  if not args then
    args = {}
  end

  return setmetatable({
    buffer = args.buffer,
    group = nil,
    name = args.name,
    on_close = args.on_close,
    on_enter = args.on_enter,
    on_leave = args.on_leave,
    position = args.position,
    window = nil,
  }, Panel)
end

function Panel:open(args)
  if not args then
    args = {}
  end

  local buffer = self.buffer or args.buffer

  if self.window then
    vim.api.nvim_set_current_win(self.window)
    return
  end

  if self.position == "bottom" then
    vim.cmd("botright split")
    self.window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(self.window, buffer)
  else
    self.window = vim.api.nvim_open_win(buffer, true, {
      relative = "",
      split = self:determine_split(),
      width = 40,
    }) or 1
  end

  vim.api.nvim_set_option_value("number", false, { win = self.window })
  vim.api.nvim_set_option_value("relativenumber", false, { win = self.window })
  vim.api.nvim_set_option_value("wrap", false, { win = self.window })

  self.group = vim.api.nvim_create_augroup((self.name .. "_%d"):format(self.window), { clear = true })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = self.group,
    callback = function()
      self:win_enter()
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = self.group,
    callback = function()
      self:win_leave()
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = self.group,
    callback = function(args)
      self:win_closed(args)
    end,
  })
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
    if self.on_enter then
      self.on_enter()
    end
  end
end

function Panel:win_leave()
  if vim.api.nvim_get_current_win() == self.window then
    if self.on_leave then
      self.on_leave()
    end
  end
end

function Panel:win_closed(args)
  local event_win = tonumber(args.match)
  if event_win == self.window then
    if self.on_close then
      self.on_close()
    end
    self.window = nil
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

function Panel:determine_split()
  if self.position then
    if self.position == "left" then
      return "left"
    elseif self.position == "bottom" then
      return "below"
    end
  end
  return "left"
end

return Panel
