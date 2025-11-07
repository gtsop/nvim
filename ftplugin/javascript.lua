vim.treesitter.start()

local buf = vim.api.nvim_get_current_buf()

if vim.b.did_ftplugin then
    return
end
vim.b.did_ftplugin = true
