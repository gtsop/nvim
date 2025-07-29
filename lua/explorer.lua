local M = {}

local state = require("state")

local project_dir = state.get_project_dir()

local explorer = require("components.explorer.controller").new({ base_path = project_dir, layout = "nest" })
explorer:register('ide', function()
  return require("ide")
end)

vim.api.nvim_create_user_command("Explorer", explorer.show, { nargs = 0 })
vim.api.nvim_create_user_command("ExplorerShow", explorer.show, { nargs = 0 })
vim.api.nvim_create_user_command("ExplorerOpen", explorer.show, { nargs = 0 })
vim.api.nvim_create_user_command("ExplorerClose", explorer.close, { nargs = 0 })

return M
