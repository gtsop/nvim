local M = {}

list_ignore = { ".git" }

function M.list_dir_files(dir, recursive)
    local path = dir
    local handle = vim.uv.fs_scandir(path)

    local dir_contents = {}

    -- Fetch directory contents from the filesystem
    while true do
      local name, typ = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end

      if typ == "directory" then
        if recursive and not vim.tbl_contains(list_ignore, name) then
          local inner_contents = M.list_dir_files(dir .. "/" .. name, true)
          if inner_contents then
            vim.list_extend(dir_contents, inner_contents)
          end
        end
      else
        table.insert(dir_contents, dir .. "/" .. name)
      end
    end

    table.sort(dir_contents)

    return dir_contents
end

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

function M.create_scratch_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.api.nvim_buf_set_name(buf, "")

  return buf
end

function M.strip_prefix(string, prefix)
  return string:gsub("^" .. vim.pesc(prefix), "")
end

function M.tbl_strip_prefix(table, prefix)
  return vim.tbl_map(function (s)
    return M.strip_prefix(s, prefix)
  end, table)
end

return M
