return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".git" },
  settings = {
    Lua = {
      workspace = {
        ignoreDir = { "test" },
      },
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = {
        "after_each",
        "before_each",
        "describe",
        "it",
        "stub",
        "vim",
        }
      }
    }
  }
}
