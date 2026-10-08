function log(...)
  local args = { ... }
  vim.schedule(function()
    for i, v in ipairs(args) do
      args[i] = vim.inspect(v)
    end
    vim.notify(table.concat(args, " "))
  end)
end

return log
