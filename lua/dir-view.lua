local dir_view_group = vim.api.nvim_create_augroup("DirViewGroup", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
  group = dir_view_group,
  callback = function(args)
    local stat = vim.uv.fs_stat(args.file)

    if not stat then
      return
    end

    if stat.type ~= "directory" then
      return
    end

    local path = args.file
    local buffer = args.buf
    local handle = vim.uv.fs_scandir(path)

    local dir_contents = {}

    -- Fetch directory contesnts from the filesystem
    while true do
      local name, typ = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end

      table.insert(dir_contents, { name = name, is_dir = (typ == "directory") })
    end

    -- Sort directory entries
    table.sort(dir_contents, function(a, b)
      if a.is_dir ~= b.is_dir then
        return a.is_dir
      end

      return a.name < b.name
    end)

    local lines = {}
    for index, entry in ipairs(dir_contents) do
      if entry.is_dir then
        table.insert(lines, entry.name .. "/")
      else
        table.insert(lines, entry.name)
      end
    end

    vim.bo[buffer].modifiable = true
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].modifiable = false

    vim.bo[buffer].buftype = "nofile"
    vim.bo[buffer].bufhidden = "wipe"
    if not vim.b.is_explorer then
      vim.bo[buffer].filetype = "dir-view"
    end
  end
})
