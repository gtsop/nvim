local fs = require("utils.fs")

local directory_view = require("views.directory")

local dir_view_group = vim.api.nvim_create_augroup("DirViewGroup", { clear = true })

local function sort_by_dir_by_name(a, b)
  if a[2] ~= b[2] then
    return a[2] == "directory"
  end

  return a[1] < b[1]
end

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
  group = dir_view_group,
  callback = function(args)

    local path = args.file

    if not fs.is_dir(path) then
      return
    end

    local contents = fs.list_dir_contents(path)

    table.sort(contents, sort_by_dir_by_name)

    local lines = directory_view.render(contents)

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


