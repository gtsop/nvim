local M = {}

local list_ignore = { ".git", "node_modules", "build" }

function M.list_dir_files(dir, recursive)
  local path = dir
  local handle = vim.uv.fs_scandir(path)
  if not handle then
    return {}
  end

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

function M.create_scratch_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.api.nvim_buf_set_name(buf, " ")

  return buf
end

function M.strip_prefix(string, prefix)
  return string:gsub("^" .. vim.pesc(prefix), "")
end

function M.tbl_strip_prefix(table, prefix)
  return vim.tbl_map(function(s)
    return M.strip_prefix(s, prefix)
  end, table)
end

function M.subsequence_score(sequence_str, test_str, case_sensitive)
  if not sequence_str or not test_str then
    return nil
  end

  if not case_sensitive then
    test_str = string.lower(test_str)
    sequence_str = string.lower(sequence_str)
  end

  -- Invert strings to favor results by the end of the line
  sequence_str = string.reverse(sequence_str)
  test_str = string.reverse(test_str)

  local score = 0
  local sequence = sequence_str

  for test_str_ch in test_str:gmatch(".") do
    local ch_index = string.find(sequence, test_str_ch, 1, true)

    if not ch_index then
      return { is_subsequence = false, score = 0 }
    end

    score = score - ch_index + 1

    sequence = sequence:sub(ch_index + 1)
  end

  score = score - #sequence

  return { is_subsequence = true, score = score }
end

function M.rank_by_subsequence(tbl, subsequence)
  local rank = {}

  for _, item in ipairs(tbl) do
    local result = M.subsequence_score(item, subsequence)

    if result then
      if result.is_subsequence then
        table.insert(rank, { score = result.score, value = item })
      end
    end
  end

  table.sort(rank, function(a, b)
    return a.score > b.score
  end)

  return vim.tbl_map(function(i)
    return i.value
  end, rank)
end

function M.tbl_slice(tbl, first, last)
  local len = #tbl
  -- default to full range
  first = first or 1
  last = last or len

  -- handle negative indices
  if first < 0 then
    first = len + first + 1
  end
  if last < 0 then
    last = len + last + 1
  end

  -- clamp bounds
  if first < 1 then
    first = 1
  end
  if last > len then
    last = len
  end

  -- build the slice
  local out = {}
  for i = first, last do
    out[#out + 1] = tbl[i]
  end
  return out
end

function M.tbl_to_lower(tbl)
  return vim.tbl_map(string.lower, tbl)
end

function M.win_get_buf_filetype(win_id)
  local win_buf = vim.api.nvim_win_get_buf(win_id)

  return vim.api.nvim_buf_get_option(win_buf, "filetype")
end

function M.request_window_to_edit_code()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    vim.print(win)
    local filetype = M.win_get_buf_filetype(win)
    vim.print("checking " .. filetype)
    if filetype ~= "dir-view.explorer" then
      return win
    end
  end

  return vim.api.get_current_win()
end

return M
