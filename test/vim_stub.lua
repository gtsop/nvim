---@meta _                     
if _G.vim then return end

require("polyfills")
require("test.helpers.assertions")

_G.vim = {
  uv  = {
    fs_scandir = function(path) return path end,
    fs_scandir_next = function(handle) end,
  },
  api = setmetatable({}, {
    __index = function(t,k)  t[k] = function() end; return t[k] end
  }),
  keymap = {
    set = function() return 1 end,
  }
}
