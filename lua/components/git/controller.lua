local M = {}
M.__index = M

function M.new(opts)
  local self = setmetatable({ ide = opts.ide }, M)

  local model = {}
  local view = {}

  local blame = require("components.git.actions.blame").create(model, view, self)

  vim.api.nvim_create_user_command("GitBlame", blame, { nargs = 0 })

  return self
end

return M
