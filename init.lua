-- We have disabled everything, so let's stuff putting back things
vim.cmd("filetype plugin on")

-- Whitespace stuff
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

require("dir-view")
require("explorer")
require("shortcuts")

vim.api.nvim_create_user_command('Reload', function() 
  vim.cmd('source $HOME/.config/nvim/init.lua') 
end, {})
