-- Reset all colors
for name,_ in pairs(vim.api.nvim_get_hl(0, {})) do vim.api.nvim_set_hl(0, name, {}) end
vim.opt.termguicolors = true

-- Reference:
-- https://www.ditig.com/256-colors-cheat-sheet#xterm-system-colors
local palette = {
  gray_27 = "#444444",
  cadet_blue = "#5faf87",
  teal = "#008080"
}

-- Neovim Groups
vim.api.nvim_set_hl(0, "Comment", {
  fg = palette.gray_27
})

vim.api.nvim_set_hl(0, "String", {
  fg = palette.cadet_blue
})

vim.api.nvim_set_hl(0, "RegEx", {
  fg = palette.teal
})


-- Tree-Sitter groups
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "@string", { link = "String" })
vim.api.nvim_set_hl(0, "@regex", { link = "RegEx" })

-- LSP Groups
vim.api.nvim_set_hl(0, "@lsp.type.comment", { link = "Comment" })
