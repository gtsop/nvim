if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

local state = require("state")
local utils = require("utils")

-- Press "Enter" to edit the file under cursor
vim.keymap.set("n", "<CR>", function()
  local path = vim.api.nvim_buf_get_name(0)
  local filename = vim.api.nvim_get_current_line()

  local full_path = vim.fs.normalize(path .. "/" .. filename)

  if utils.is_dir(full_path) then
    vim.cmd("edit " .. full_path)
  else
    local next_win = utils.get_next_win()
    local buff_id = vim.fn.bufadd(full_path)

    vim.api.nvim_win_set_buf(next_win, buff_id)
    vim.api.nvim_set_current_win(next_win)
  end
end, { buffer = true, silent = true, noremap = true })

-- Press "-" to go to parent directory
vim.keymap.set("n", "-", function()
  local path = vim.api.nvim_buf_get_name(0)
  local parent = vim.fs.dirname(path)
  vim.cmd("edit " .. parent)
end, { buffer = true, silent = true, noremap = true})
  
-- Press "0" to go to the initial directory being edited
vim.keymap.set("n", "0", function() 
  local project_dir = state.get_project_dir()
  vim.cmd("edit " .. project_dir)
end, { buffer = true, silent = true, noremap = true})

-- Press "a" to add a file
vim.keymap.set("n", "a", function()
  local dir = vim.api.nvim_buf_get_name(0)

  vim.ui.input({ prompt = "New file: ", default = dir .. "/" }, function(new_file) 
    if new_file then
      vim.fn.mkdir(vim.fs.dirname(new_file), "p")
      vim.fn.writefile({}, new_file)
      vim.cmd("e!")
    end
  end)
  vim.api.nvim_echo({}, false, {})
end, { buffer = true, silent = true, noremap = true })

-- Press "d" to delete a file
vim.keymap.set("n", "d", function()

  local path = vim.api.nvim_buf_get_name(0)
  local filename = vim.api.nvim_get_current_line()

  local full_path = vim.fs.normalize(path .. "/" .. filename)

  vim.ui.input({ prompt = "Are you sure you want to delete '" .. full_path .. "' ? [y/n]: " }, function(answer) 
    if answer == "y" then
      vim.fn.delete(full_path)
      vim.cmd("e!")
    end
  end)
  vim.api.nvim_echo({}, false, {})
end, { buffer = true, silent = true, noremap = true })

-- Press "m" to move a file
vim.keymap.set("n", "m", function()

  local path = vim.api.nvim_buf_get_name(0)
  local filename = vim.api.nvim_get_current_line()

  local full_path = vim.fs.normalize(path .. "/" .. filename)

  vim.ui.input({ prompt = "Give new file location for", default = full_path }, function(new_file) 
    if new_file then
      vim.fn.rename(full_path, new_file)
      vim.cmd("e!")
    end
  end)
  vim.api.nvim_echo({}, false, {})
end, { buffer = true, silent = true, noremap = true })



-- Press "r" to refresh view
vim.keymap.set("n", "r", function()
  vim.cmd("e!")
end, { buffer = true, silent = true, noremap = true })
