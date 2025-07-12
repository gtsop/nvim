local state = require("state")
local utils = require("utils")
local input = require("input")

vim.api.nvim_create_user_command("FileFinderShowOld", function()
  vim.ui.input({ prompt = "File: " }, function(choice)

    local project_dir = state.get_project_dir()

    local file = utils.find_file(choice, project_dir)

    if file then
      vim.cmd("edit " .. file)
    else
      vim.print("")
      vim.print("Unable to locate: '" .. choice .. "'")
    end
  end)
end, { nargs = 0 })


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
      vim.cmd("edit " .. project_dir .. "/" .. choice)
    end
  end,
  function()
    input.close()
  end)

end, { nargs = 0 })
