vim.cmd("filetype plugin on")

require("polyfills")

local state = require('state')

-- Cursor style
vim.opt.guicursor = "a:ver1"

-- Whitespace stuff
vim.g.mapleader = " "
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.swapfile = false
vim.opt.winborder = 'rounded'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.o.completeopt = 'menu,menuone,noinsert'

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

require("colors")
require("file-finder")
require("lsp")
require("shortcuts")

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    state.detect_project_dir()
  end
})

