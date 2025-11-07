-- Ctrl + S: Save file
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<esc>:w<CR>", { silent = true })

-- Ctrl + q: Exit neovim
vim.keymap.set({ "n", "i", "v" }, "<C-q>", "<esc>:qa!<CR>", { silent = true })

-- Leader + w: Close current window
vim.keymap.set({ "n", "v" }, "<Leader>w", "<esc>:close<CR>", { silent = true })

-- Ctrl + p: Show File Finder
vim.keymap.set({ "n", "v" }, "<C-p>", "<esc>:FileFinderShow<CR>", { silent = true })

-- Ctrl + f: Search
vim.keymap.set({ "n", "v" }, "<C-f>", "<esc>/", { silent = true })
