if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

local ide = require("ide")

vim.keymap.set('n', 'gtt', function()
  ide.from_code_to_test(vim.api.nvim_buf_get_name(0))
end)

vim.keymap.set('n', 'gtc', function()
  ide.from_test_to_code(vim.api.nvim_buf_get_name(0))
end)
