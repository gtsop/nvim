local state = require("state")
local utils = require("utils")

vim.api.nvim_create_user_command("FileFinderShow", function()
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
