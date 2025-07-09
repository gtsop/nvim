local M = {}

function M.is_dir(path)
  local file = vim.uv.fs_stat(vim.fs.normalize(path))

  return file and file.type == "directory"
end

function M.get_next_win()
  local current_win = vim.api.nvim_get_current_win()

  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins == 1 then
    return current_win
  end

  for i, win in ipairs(wins) do
    if win == current_win then
      -- Black mathic
      return wins[i % #wins + 1]
    end
  end
end

local do_not_traverse = { ".git" }

function M.find_file(file_to_find, root_dir)
  local scanner = vim.uv.fs_scandir(root_dir)
  if not scanner then
    return nil
  end

  while true do
    local name, typ = vim.uv.fs_scandir_next(scanner)
    if not name then
      break
    end

    local full_name = root_dir .. "/" .. name

    if typ == "directory" then
      if not vim.tbl_contains(do_not_traverse, name) then
        local hit = M.find_file(file_to_find, full_name)
        if hit then
          return hit
        end
      end
    else
      if name == file_to_find then
        return full_name
      end
    end
  end

  return nill
end

return M
