local function list_dir_contents(path)
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

      table.insert(contents, { name, typ })
    end

    return contents
end

return list_dir_contents

