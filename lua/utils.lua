local M = {}

function M.is_dir(path)
  local file = vim.uv.fs_stat(vim.fs.normalize(path))

  return file and file.type == "directory"
end

return M
