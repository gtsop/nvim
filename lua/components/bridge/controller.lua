local M = {}
M.__index = M

function M.new(opts)
  local self = setmetatable({ ide = opts.ide }, M)

  -- Register actions
  self.edit_test_file = require("components.bridge.actions.edit-test-file").create(nil, nil, self)
  self.edit_code_file = require("components.bridge.actions.edit-code-file").create(nil, nil, self)

  -- Register commands
  vim.api.nvim_create_user_command("BridgeEditTestFile", self.edit_test_file, { nargs = 0 })
  vim.api.nvim_create_user_command("BridgeEditCodeFile", self.edit_code_file, { nargs = 0 })

  return self
end

return M
