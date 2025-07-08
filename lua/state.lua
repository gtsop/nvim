local M = {}

local utils = require("utils")

local project_dir = ""

function M.get_project_dir()
  return project_dir
end

function M.set_project_dir(new_project_dir)
  project_dir = new_project_dir
end

function M.detect_project_dir()
  if utils.is_dir(project_dir) then
    return
  end

  local current_file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))

  if utils.is_dir(current_file) then
    project_dir = current_file
  else
    project_dir = vim.fs.dirname(current_file)
  end 
end

return M
