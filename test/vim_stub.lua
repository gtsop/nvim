---@meta _                     
if _G.vim then return end

_G.vim = {
  uv  = {
    fs_scandir = function(path) return true end,
    fs_scandir_next = function(handle) end,
  },
  api = setmetatable({}, {
    __index = function(t,k)  t[k] = function() end; return t[k] end
  })
}
