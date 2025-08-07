if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

vim.treesitter.start()

local ide = require("ide")


