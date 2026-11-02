local function exec(args, ide)
  return "disabled pending IDE/LSP API: expose diagnostics as data (see REVIEW on lua/lsp.lua)"
end

local name = "ide.get_diagnostics"

local schema = {
  type = "function",
  ["function"] = {
    name = "ide.get_diagnostics",
    description = "DISABLED. Will return diagnostics for a path (severity/limit filters) once LSP data APIs exist.",
    parameters = {
      type = "object",
      properties = {
        path = {
          type = "string",
          description = "Optional file path to filter diagnostics.",
        },
        severity = {
          type = "string",
          description = "Optional severity filter (error/warn/info/hint).",
        },
        limit = {
          type = "number",
          description = "Max diagnostics to return.",
        },
      },
    },
  },
}

return {
  _enabled = false,
  exec = exec,
  name = name,
  schema = schema,
}
