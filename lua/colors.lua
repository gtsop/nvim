-- Reset all colors
for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
  vim.api.nvim_set_hl(0, name, {})
end
vim.opt.termguicolors = true

-- Reference:
-- https://www.ditig.com/256-colors-cheat-sheet#xterm-system-colors
local xterm_palette = {
  black = "#000000",
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
  white = "#ffffff",
}

local rgb_palette = {
  peach = "#D9A299",
  brown = "#a0787b",
  almond = "#EADDCA",
  dark_brown = "#6b6263",
  steel_blue_gray = "#818FB4",
  light_blue = "#9cc4dc",
  dark_blue = "#596e7a",
}

local brand_palette = {
  react_blue = "#06bcee",
}

-- Neovim Code Groups
vim.api.nvim_set_hl(0, "Normal", { fg = xterm_palette.white })
vim.api.nvim_set_hl(0, "Comment", { fg = xterm_palette.gray_27 })
vim.api.nvim_set_hl(0, "Function", { fg = xterm_palette.medium_purple3 })
vim.api.nvim_set_hl(0, "RegEx", { fg = xterm_palette.teal })
vim.api.nvim_set_hl(0, "String", { fg = xterm_palette.cadet_blue })
vim.api.nvim_set_hl(0, "Visual", { fg = xterm_palette.white, bg = xterm_palette.medium_purple4 })

-- Neovim UI Groups
vim.api.nvim_set_hl(0, "Search", { fg = xterm_palette.white, bg = xterm_palette.medium_purple4 })
vim.api.nvim_set_hl(0, "CurSearch", { fg = xterm_palette.white, bg = xterm_palette.fuchsia })
vim.api.nvim_set_hl(0, "IncSearch", { fg = xterm_palette.white, bg = xterm_palette.medium_purple4 })
vim.api.nvim_set_hl(0, "CursorLine", { bg = xterm_palette.gray7 })
vim.api.nvim_set_hl(0, "CursorColumn", { bg = xterm_palette.gray7 })

-- Tree-Sitter groups
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "@keyword", { fg = rgb_palette.brown })
vim.api.nvim_set_hl(0, "@regex", { link = "RegEx" })
vim.api.nvim_set_hl(0, "@string", { link = "String" })

-- LSP Groups
vim.api.nvim_set_hl(0, "@lsp.type.comment", { link = "Comment" })

-- Explorer
vim.api.nvim_set_hl(0, "@explorer.directory", { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@explorer.hidden", { link = "Comment" })

-- Gherkin
vim.api.nvim_set_hl(0, "@keyword.background", { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.feature", { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.given", { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.given_and", { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.scenario", { fg = rgb_palette.steel_blue_gray })
vim.api.nvim_set_hl(0, "@keyword.then", { fg = xterm_palette.cadet_blue })
vim.api.nvim_set_hl(0, "@keyword.then_and", { fg = xterm_palette.cadet_blue })
vim.api.nvim_set_hl(0, "@keyword.when", { fg = rgb_palette.peach })
vim.api.nvim_set_hl(0, "@keyword.when_and", { fg = rgb_palette.peach })
vim.api.nvim_set_hl(0, "@text.description", { fg = xterm_palette.gray, italic = true })
vim.api.nvim_set_hl(0, "@text.title", { fg = rgb_palette.peach, italic = true })

-- JavaScript
vim.api.nvim_set_hl(0, "@javascript.keyword", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@javascript.regex", { link = "@regex" })
vim.api.nvim_set_hl(0, "@javascript.literal_object_key", { fg = rgb_palette.almond })
vim.api.nvim_set_hl(0, "@javascript.literal_string", { link = "@string" })
vim.api.nvim_set_hl(0, "@javascript.identifier", { link = "Normal" })

-- JSX
-- vim.api.nvim_set_hl(0, "@jsx.self_tag", { fg = rgb_palette.light_blue })
-- vim.api.nvim_set_hl(0, "@jsx.start_tag", { fg = rgb_palette.light_blue })
vim.api.nvim_set_hl(0, "@jsx.end_tag", { fg = rgb_palette.dark_blue })

vim.api.nvim_set_hl(0, "@jsx.tag_name", { fg = rgb_palette.light_blue })
vim.api.nvim_set_hl(0, "@jsx.attribute_name", { fg = rgb_palette.almond })

-- HTML
vim.api.nvim_set_hl(0, "@html.comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "@html.start_tag", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@html.end_tag", { fg = rgb_palette.dark_brown })

-- Graphql
vim.api.nvim_set_hl(0, "@graphql.comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "@graphql.keyword", { link = "@keyword" })
-- vim.api.nvim_set_hl(0, "@graphql.identifier", { fg = xterm_palette.light_goldenrod2 })
-- vim.api.nvim_set_hl(0, "@graphql.scalar", { fg = xterm_palette.fuchsia })
-- vim.api.nvim_set_hl(0, "@graphql.type", { fg = xterm_palette.fuchsia })

-- Popup Gropus
vim.api.nvim_set_hl(0, "Pmenu", { bg = xterm_palette.gray7 })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = xterm_palette.white, fg = xterm_palette.black })
