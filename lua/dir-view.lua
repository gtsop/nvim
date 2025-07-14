local fs = require("utils.fs")

local dir_view_group = vim.api.nvim_create_augroup("DirViewGroup", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
  group = dir_view_group,
  callback = function(args)

    local path = args.file

    if not fs.is_dir(path) then
      return
    end

    local contents = fs.read_dir_contents(path)

    table.sort(contents, sort_by_dir_by_name)

    local lines = {}
    for index, entry in ipairs(contents) do
      if entry.is_dir then
        table.insert(lines, entry.name .. "/")
      else
        table.insert(lines, entry.name)
      end
    end

    local buffer = args.buf

    vim.bo[buffer].modifiable = true
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].modifiable = false

    vim.bo[buffer].buftype = "nofile"
    vim.bo[buffer].bufhidden = "wipe"

    if vim.w.is_explorer then
      vim.bo[buffer].filetype = "dir-view.explorer"
    else
      vim.bo[buffer].filetype = "dir-view"
    end
  end
})

function sort_by_dir_by_name(a, b)
  if a.is_dir ~= b.is_dir then
    return a.is_dir
  end

  return a.name < b.name
end
