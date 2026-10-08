return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".git" },
  settings = {
    Lua = {
      workspace = {
        ignoreDir = { "test" },
        library = {
          [vim.fn.expand("~/.local/share/love2d-library")] = true,
        },
        checkThirdParty = false,
      },
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = {
          "love",
          "after_each",
          "before_each",
          "describe",
          "it",
          "stub",
          "vim",
        },
      },
    },
  },
}
