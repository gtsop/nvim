local M = {}

function M.create(m, v, c)
  return function()
    local filepath = c.ide.get_current_file()
    local line = c.ide.get_current_line()

    local result = vim.fn.system({
      "git",
      "blame",
      "-L",
      line .. "," .. line,
      "--",
      filepath,
    })

    vim.print(result)
  end
end

return M
