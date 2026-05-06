return {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",
      },
    },
  },
}
