-- Arbitrary shell execution is intentionally unavailable to the LLM.
-- Tools that need external programs must call shared.run_argv() with a fixed
-- allowlisted argv (see _shared.lua). This module stays disabled as a hard stop.

local function exec(args, ide)
  return "SecurityError: arbitrary shell execution is forbidden"
end

local name = "shell.run"

local schema = {
  type = "function",
  ["function"] = {
    name = "shell.run",
    description = "DISABLED. Arbitrary shell commands are not available.",
    parameters = {
      type = "object",
      properties = vim.empty_dict(),
    },
  },
}

return {
  _enabled = false,
  exec = exec,
  name = name,
  schema = schema,
}
