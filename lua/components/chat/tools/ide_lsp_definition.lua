local function exec(args, ide)
  return "disabled pending IDE/LSP API: expose definition locations as data (see REVIEW on lua/lsp.lua)"
end

local name = "ide.lsp_definition"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.lsp_definition",
    description = "DISABLED. Will resolve LSP definition at path:line:col once a data API exists.",
    parameters = {
      type = "object",
      properties = {
        path = { type = "string", description = "File path." },
        line = { type = "number", description = "1-based line." },
        col = { type = "number", description = "1-based column." },
      },
      required = { "path", "line", "col" },
    },
  },
}

return {
  _enabled = false,
  exec = exec,
  name = name,
  schema = schema,
}
