vim.g.mapleader = " "

-- Leader + S: Save file
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<esc>:w<CR>', { silent = true })

-- Leader + q: Exit neovim
vim.keymap.set({ 'n', 'i', 'v' }, '<C-q>', '<esc>:qa!<CR>', { silent = true })

-- Leader + w: Close current window
vim.keymap.set({ 'n', 'v' }, '<Leader>w', '<esc>:close<CR>', { silent = true })

-- Leader + e: Close current window
vim.keymap.set({ 'n', 'v' }, '<Leader>e', '<esc>:ExplorerShow<CR>', { silent = true })




