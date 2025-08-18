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
vim.opt.completeopt = 'menu,menuone,noinsert,noselect,popup'
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

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

vim.keymap.set('n', '<esc>', "<cmd>nohlsearch<cr><esc>", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.schedule(function()
      vim.cmd("nohlsearch")
    end)
  end,
})
