local M = {}
M.__index = M

function M.new(opts)
  local self = setmetatable({}, M)
  opts = opts or {}

  vim.opt.completeopt = opts.completeopt or "menu,menuone,noinsert,noselect,popup"
  vim.opt.pumheight = opts.pumheight or 10

  local group = vim.api.nvim_create_augroup("UserLspCompletion", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if not client then
        return
      end

      if not client:supports_method("textDocument/completion") then
        return
      end

      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = opts.autotrigger ~= false,
      })
    end,
  })

  vim.keymap.set("i", "<C-Space>", function()
    vim.lsp.completion.get()
  end, {
    desc = "Trigger LSP completion",
  })

  vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
      local selected = vim.fn.complete_info({ "selected" }).selected

      if selected ~= -1 then
        return vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
      end

      return vim.api.nvim_replace_termcodes("<C-e><CR>", true, false, true)
    end

    return "\r"
  end, {
    expr = true,
    desc = "Confirm completion only if selected",
  })

  return self
end

return M
