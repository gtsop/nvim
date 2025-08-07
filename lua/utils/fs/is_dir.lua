-- @param path string
-- @return boolean
local function is_dir(path)
  local stat = vim.uv.fs_stat(vim.fs.normalize(path))
  return stat and stat.type == "directory"
end

return is_dir
