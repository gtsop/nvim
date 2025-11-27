local M = {}

local utils = require("utils")
local state = require("state")
local project_dir = state.get_project_dir()

---------------------------
-- AUTOCOMPLETE
---------------------------
local autocomplete = require("components.autocomplete.controller").new()

---------------------------
-- BRIDGE
---------------------------

local bridge = require("components.bridge.controller").new()
bridge:register("ide", function()
  return M
end)

vim.keymap.set("n", "gtt", "<esc>:BridgeEditTestFile<cr>")
vim.keymap.set("n", "gtc", "<esc>:BridgeEditCodeFile<cr>")

---------------------------
-- EXPLORER
---------------------------

local explorer = require("components.explorer.controller").new({
  base_path = project_dir,
  window_width = 30,
})
explorer:register("ide", function()
  return M
end)

vim.keymap.set("n", "gte", "<esc>:ExplorerFindFile<cr>")
vim.keymap.set("n", "<Leader>e", "<esc>:ExplorerShow<cr>")

---------------------------
-- FindText
---------------------------

local findText = require("components.find-text.controller").new({
  base_path = project_dir,
})
findText:register("ide", function()
  return M
end)

vim.keymap.set("n", "<C-f>", "/", { noremap = true })
vim.keymap.set("x", "<C-f>", [["zy/<C-r>z<CR>]], { noremap = true, silent = true })

vim.keymap.set("n", " ", function()
  local pat = vim.fn.getreg("/") or ""
  if pat ~= "" then
    vim.cmd("FindText " .. pat)
  else
    vim.api.nvim_feedkeys(":FindText ", "n", false)
  end
end, { noremap = true, silent = true })

vim.keymap.set("x", " ", '"zy:<C-u>FindText <C-r>z<CR>', { noremap = true, silent = true })
--vim.keymap.set("x", " ", function()
--  vim.cmd([[normal! "zy]])
--  local sel = vim.fn.getreg("z")
--  if sel ~= "" then
--    vim.cmd("SeekerFind " .. vim.fn.shellescape(sel))
-- end
--end, { noremap = true, silent = true })

---------------------------
-- LINTER
---------------------------

local linter = require("components.linter.controller").new()
---------------------------
-- FORMATTER
---------------------------

local formatter = require("components.formatter.controller").new()

---------------------------
-- TREE SITTER
---------------------------

vim.treesitter.language.register("javascript", { "javascriptreact", "typescript", "typescriptreact" })
vim.treesitter.language.register("html", { "handlebars" })

---------------------------
-- FILE TYPES
---------------------------

vim.filetype.add({
  extension = { feature = "gherkin" },
})

local function get_file_edit_window()
  local avoid_filetypes = { "explorer" }

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not table.contains(avoid_filetypes, utils.win_get_buf_filetype(win)) then
      return win
    end
  end

  return vim.api.nvim_get_current_win()
end

M.edit = function(full_path)
  local buff_id = vim.fn.bufadd(full_path)
  local win_id = nil

  win_id = get_file_edit_window()

  vim.api.nvim_win_set_buf(win_id, buff_id)
  vim.api.nvim_set_current_win(win_id)
end

function M.create_file(path, callback)
  local dir = vim.fs.dirname(path)

  local new_file = vim.fn.input("New file: ", dir .. "/", "file")

  if new_file then
    vim.fn.mkdir(vim.fs.dirname(new_file), "p")

    -- create file
    if new_file:sub(-1) ~= "/" then
      vim.fn.writefile({}, new_file)
    end

    if callback then
      callback()
    end
  end
end

function M.delete_file(path, callback)
  vim.ui.input({ prompt = "Are you sure you want to delete '" .. path .. "' ? [y/n]: " }, function(answer)
    if answer == "y" then
      vim.fn.delete(path)
      if callback then
        callback()
      end
    end
  end)
end

function M.move_file(path, callback)
  vim.ui.input({ prompt = "Give new file location for: ", default = path }, function(new_file)
    if new_file then
      vim.fn.rename(path, new_file)
      if callback then
        callback()
      end
    end
  end)
end

function M.copy_file(path, callback)
  vim.ui.input({ prompt = "Copy file to new location: ", default = path }, function(new_file)
    if new_file then
      vim.fn.mkdir(vim.fn.fnamemodify(new_file, ":h"), "p")
      vim.fn.writefile(vim.fn.readfile(path), new_file)
      if callback then
        callback()
      end
    end
  end)
end

return M
