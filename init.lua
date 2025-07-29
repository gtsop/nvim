vim.cmd("filetype plugin on")

-- vim.opt.runtimepath:remove('/usr/share/nvim/runtime')
-- vim.opt.runtimepath:remove('/usr/share/nvim/runtime/after')

require("polyfills")

local state = require('state')

-- We first declare the config reset code, if stuff goes wrong down the 
-- config we can at least have this command to reload once we fix
local _builtins = {}
for name in pairs(package.loaded) do
  _builtins[name] = true
end

vim.api.nvim_create_user_command("RC", function()
  for name in pairs(package.loaded) do
    if not _builtins[name] then
      package.loaded[name] = nil
    end
  end

  vim.cmd("luafile " .. vim.fn.stdpath("config") .. "/init.lua")

  state.detect_project_dir()
end, { nargs = 0 })

-- We have disabled everything, so let's stuff putting back things

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

-- Cursor style
vim.opt.guicursor = "a:ver1"

-- Whitespace stuff
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.swapfile = false
vim.opt.winborder = 'rounded'

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

require("file-finder")
require("shortcuts")
require("lsp")

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    state.detect_project_dir()
  end
})
