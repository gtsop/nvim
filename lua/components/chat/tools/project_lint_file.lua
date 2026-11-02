local function exec(args, ide)
  return "disabled pending linter path API: return diagnostics for a path without buffer-only side effects (see REVIEW on linter controller)"
end

local name = "project.lint_file"

local schema = {
  type = "function",
  ["function"] = {
    name = "project.lint_file",
    description = "DISABLED. Will lint a project file and return compact diagnostics once a path-based API exists.",
    parameters = {
      type = "object",
      properties = {
        path = { type = "string", description = "Project file path." },
      },
      required = { "path" },
    },
  },
}

return {
  _enabled = false,
  exec = exec,
  name = name,
  schema = schema,
}
