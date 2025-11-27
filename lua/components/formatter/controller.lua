local M = {}
M.__index = M

function M.new()
  local self = setmetatable({}, M)

  function self.run_cmd(cmd, args, callback)
    local stdout = vim.fn.system(cmd, args)
    local ok = vim.v.shell_error == 0

    if ok then
      local out = vim.split(stdout or "", "\n", { plain = true })
      callback(out)
    else
      vim.notify(("Fromat failed:\n%s"):format(stdout), vim.log.levels.ERROR)
    end
  end

  local model = require("components.formatter.model").new()
  local view = require("components.formatter.view").new()

  local format_stylua = require("components.formatter.actions.format-stylua").create(model, view, self)
  local format_prettier = require("components.formatter.actions.format-prettier").create(model, view, self)

  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.json" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.js", "*.ts" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.mjs", "*.cjs" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.jsx", "*.tsx" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.md", "*.mdx" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.css", "*.html", "*.hbs" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.graphql" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.yml", ".yaml" }, callback = format_prettier })
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.lua" }, callback = format_stylua })

  return self
end

return M
