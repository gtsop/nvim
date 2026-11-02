local Toolkit = {}
Toolkit.__index = Toolkit

local state = require("state")
local basename = require("utils.fs.path.basename")
local list_dir_contents = require("utils.fs.list_dir_contents")

-- REVIEW(chat-tools): for small models, support selective tool loading (by name/tag/model)
-- so schemas do not burn context. Consider skipping non-*.lua entries and a result-size
-- budget wrapper around exec(). Async tool results would also need toolkit + ollama changes.
function Toolkit.new(opts)
  local self = setmetatable({}, Toolkit)

  local tool_path = vim.fn.stdpath("config") .. "/lua/components/chat/tools"
  local tool_files = list_dir_contents(tool_path)

  local tools = {}
  local tool_names = {}
  local tool_schemas = {}

  for _, file in ipairs(tool_files) do
    local tool = require("components.chat.tools." .. basename(file[1], true))
    if tool and type(tool) == "table" and tool._enabled then
      tools[tool.name] = tool
      table.insert(tool_names, tool.name)
      table.insert(tool_schemas, tool.schema)
    end
  end

  function self.list()
    return tool_schemas
  end

  function self.exec(name, args, ide)
    -- Defense in depth: never allow LLM-facing shell tools even if re-enabled by mistake.
    if type(name) == "string" and (name == "shell.run" or name:match("^shell%.")) then
      return "SecurityError: arbitrary shell execution is forbidden"
    end
    local tool = tools[name]
    if not tool then
      return "ArgError: unknown tool: " .. tostring(name)
    end
    return tool.exec(args, ide)
  end

  return self
end

return Toolkit
