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
vim.cmd("filetype plugin on")

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
