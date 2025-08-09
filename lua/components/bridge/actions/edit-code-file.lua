local M = {}

local fs = require("utils.fs")
local path = require("utils.fs.path")

function M.create(_, _, c)
  return function()
    local file = vim.api.nvim_buf_get_name(0)

    local dirname = path.dirname(file)
    local basename = path.basename(file, true)
    local extension = path.extension(file)

    local code_file = ''

    if extension == "lua" then
      code_file = dirname .. "/" .. basename:gsub(".test", "") .. ".lua"
    elseif extension == "js" then
      code_file = dirname .. "/" .. basename:gsub(".test", "") .. ".js"
    elseif extension == "jsx" then
      code_file = dirname .. "/" .. basename:gsub(".test", "") .. ".jsx"
    elseif extension == "ts" then
      code_file = dirname .. "/" .. basename:gsub(".test", "") .. ".ts"
    elseif extension == "tsx" then
      code_file = dirname .. "/" .. basename:gsub(".test", "") .. ".tsx"
    end

    if fs.is_file(code_file) then
      c:service("ide").edit(code_file)
    else
      vim.print("Failed to find code file at: " .. code_file)
    end
  end
end

return M
