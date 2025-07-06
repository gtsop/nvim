vim.g.mapleader = ","

-- Leader + S: Save file
vim.keymap.set({ 'n', 'i', 'v' }, '<Leader>s', '<esc>:w<CR>', { silent = true })

-- Leader + q: Exit neovim
vim.keymap.set({ 'n', 'i', 'v' }, '<Leader>q', '<esc>:qa!<CR>', { silent = true })

-- Leader + w: Close current window
vim.keymap.set({ 'n', 'i', 'v' }, '<Leader>w', '<esc>:close<CR>', { silent = true })

-- Leader + e: Close current window
vim.keymap.set({ 'n', 'i', 'v' }, '<Leader>e', '<esc>:ExplorerShow<CR>', { silent = true })




