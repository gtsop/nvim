local M = {}
M.__index = M

function M.new()
  local self = setmetatable({}, M)

  -- Register actions
  function self.go_to_unit_test()
    local dir, base, ext = split_path(full_path)

    local test_path = dir .. "/" .. base .. ".test." .. ext

    if file_exists(test_path) then
      M.edit(test_path)
    else
      vim.print("Test file: " .. test_path .. " does not exist")
    end
  end


  -- Register keymaps

  return self
end

return M
