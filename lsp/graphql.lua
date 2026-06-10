return {
  cmd = { "graphql-lsp", "server", "-m", "stream" },
  filetypes = { "graphql" },
  root_markers = { ".git", "package.json" },
  capabilities = vim.lsp.protocol.make_client_capabilities(),
}
