local LinterController = {}
LinterController.__index = LinterController

local LinterModel = require("components.linter.model")
local LinterView = require("components.linter.view")

-- REVIEW(chat-tools): add a path-based lint API that returns diagnostics as data
-- (for project.lint_file) instead of only BufWritePre buffer side effects.
function LinterController.new(opts)
  local self = setmetatable({}, LinterController)

  function self.run_cmd(cmd, args, callback, opts)
    opts = opts or {}
    local max_exit_code = opts.max_exit_code or 0
    local stdout = vim.fn.system(cmd, args)
    local code = vim.v.shell_error

    if code <= max_exit_code then
      local out = vim.split(stdout or "", "\n", { plain = true })
      callback(out)
    else
      -- vim.notify(("Linter failed:\n%s"):format(stdout), vim.log.levels.ERROR)
    end
  end

  local model = LinterModel.new()
  local view = LinterView.new()

  local lint_eslint = require("components.linter.actions.lint-eslint").create(model, view, self)

  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.json" }, callback = lint_eslint })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.js", "*.ts" }, callback = lint_eslint })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.mjs", "*.cjs" }, callback = lint_eslint })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.jsx", "*.tsx" }, callback = lint_eslint })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.graphql" }, callback = lint_eslint })

  return self
end

return LinterController
