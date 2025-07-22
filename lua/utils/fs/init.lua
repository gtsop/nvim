local M = {}

M.list_dir_contents = require("utils.fs.list_dir_contents")

function M.is_dir(path)
  local file = vim.uv.fs_stat(vim.fs.normalize(path))

  return file and file.type == "directory"
end

function M.read_dir_contents(path)

    local contents = {}

    local handle = vim.uv.fs_scandir(path)
    if not handle then
      return contents
    end

    while true do
      local name, typ = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end

      table.insert(contents, {
        path = path .. "/" .. name, 
        name = name,
        is_dir = (typ == "directory")
      })
    end
    return contents
end

return M
