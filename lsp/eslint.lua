return {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.json",
    "eslint.config.js",
    "eslint.config.mjs",
    "package.json",
  },
  settings = {
    nodePath = "",
    quiet = false,
    rulesCustomizations = {},
    run = "onType",
    validate = "on",
    experimental = { useFlatConfig = true },
    problems = { shortenToSingleLine = false },
  },
}
