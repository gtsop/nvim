-- Reset all colors
for name,_ in pairs(vim.api.nvim_get_hl(0, {})) do vim.api.nvim_set_hl(0, name, {}) end
vim.opt.termguicolors = true

-- Reference:
-- https://www.ditig.com/256-colors-cheat-sheet#xterm-system-colors
local xterm_palette = {
  cadet_blue = "#5faf87",
  gray = "#808080",
  gray3 = "#080808",
  gray7 = "#121212",
  gray_27 = "#444444",
  fuchsia = "#ff00ff",
  light_goldenrod1 = "#ffff5f",
  light_goldenrod2 = "#ffd75f",
  light_goldrenrod3 = "#ffd75f",
  light_steel_blue1 = "#d7d7ff",
  light_steel_blue3 = "#afafd7",
  medium_purple3 = "#875faf",
  medium_purple4 = "#5f5f87",
  spring_green3 = "#00af5f",
  steel_blue1 = "#5fafff",
  teal = "#008080",
  wheat = "#ffffaf",
  white = "#ffffff"
}

local rgb_palette = {
  peach = "#D9A299",
  brown = "#a0787b",
  steel_blue_gray = "#818FB4"
}

-- Neovim Code Groups
vim.api.nvim_set_hl(0, "Comment",  { fg = xterm_palette.gray_27 })
vim.api.nvim_set_hl(0, "Function", { fg = xterm_palette.medium_purple3 })
vim.api.nvim_set_hl(0, "RegEx",    { fg = xterm_palette.teal })
vim.api.nvim_set_hl(0, "String",   { fg = xterm_palette.cadet_blue })

-- Neovim UI Groups
vim.api.nvim_set_hl(0, "Search",     { fg = xterm_palette.white, bg = xterm_palette.medium_purple4 })
vim.api.nvim_set_hl(0, "CurSearch",  { fg = xterm_palette.white, bg = xterm_palette.fuchsia })
vim.api.nvim_set_hl(0, "IncSearch",  { fg = xterm_palette.white, bg = xterm_palette.medium_purple4 })
vim.api.nvim_set_hl(0, "CursorLine", { bg = xterm_palette.gray7 })
vim.api.nvim_set_hl(0, "CursorColumn", { bg = xterm_palette.gray7 })

-- Tree-Sitter groups
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "@keyword", { fg = rgb_palette.brown })
vim.api.nvim_set_hl(0, "@regex",   { link = "RegEx" })
vim.api.nvim_set_hl(0, "@string",  { link = "String" })

-- LSP Groups
vim.api.nvim_set_hl(0, "@lsp.type.comment", { link = "Comment" })

-- Explorer
vim.api.nvim_set_hl(0, "@explorer.directory", { fg = rgb_palette.steel_blue_gray})
-- vim.api.nvim_set_hl(0, "@explorer.file",    { fg = rgb_palette.steel_blue_gray })

-- Gherkin
vim.api.nvim_set_hl(0, "@keyword.background", { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.feature",    { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.given",      { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.given_and",  { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.scenario",   { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.then",       { fg = xterm_palette.cadet_blue })
vim.api.nvim_set_hl(0, "@keyword.then_and",   { fg = xterm_palette.cadet_blue })
vim.api.nvim_set_hl(0, "@keyword.when",       { fg = rgb_palette.peach })
vim.api.nvim_set_hl(0, "@keyword.when_and",   { fg = rgb_palette.peach })
vim.api.nvim_set_hl(0, "@text.description",   { fg = xterm_palette.gray, italic = true })
vim.api.nvim_set_hl(0, "@text.title",         { fg = rgb_palette.peach, italic = true })

