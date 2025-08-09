local M = {}
M.__index = M

function M.new()
  local self = setmetatable({}, M)

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.md", "*.mdx", "*.json" },
    callback = function()
      local view = vim.fn.winsaveview()
      vim.cmd([[%!prettier --stdin-filepath %]])
      vim.fn.winrestview(view)
    end
  })

  return self
end

return M
