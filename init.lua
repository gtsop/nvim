-- We have disabled everything, so let's stuff putting back things
vim.cmd("filetype plugin on")

-- Cursor style
vim.opt.guicursor = "a:ver1"

-- Whitespace stuff
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

local state = require("state")

require("dir-view")
require("explorer")
require("shortcuts")
require("file-finder")

vim.api.nvim_create_user_command('Reload', function() 
  vim.cmd('source $HOME/.config/nvim/init.lua') 
end, {})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    state.detect_project_dir()
  end
})
