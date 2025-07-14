local state = require("state")
local utils = require("utils")
local input = require("input")

function get_project_files(keyword)
  local project_dir = state.get_project_dir()
  local files = utils.list_dir_files(project_dir, true)

  return files
end

vim.api.nvim_create_user_command("FileFinderShow", function()

  local project_dir = state.get_project_dir()
  local files = get_project_files()
  local stripped = utils.tbl_strip_prefix(files, project_dir .. "/")

  input.open(function(choice)
    if not choice then return end

    local ranked_files = utils.tbl_slice(utils.rank_by_subsequence(stripped, choice, true), 1, 5)
    input.options(ranked_files)
    input.print()
  end,
  function(choice)
    input.close()
    if choice then
      local full_path = project_dir .. "/" .. choice

      local buf = vim.fn.bufadd(full_path)
      vim.fn.bufadd(full_path)

      local win = utils.request_window_to_edit_code()
      vim.api.nvim_win_set_buf(win, buf)
      vim.api.nvim_set_current_win(win)
    end
  end,
  function()
    input.close()
  end)

end, { nargs = 0 })
