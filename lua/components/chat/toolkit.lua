local Toolkit = {}
Toolkit.__index = Toolkit

local state = require("state")
local basename = require("utils.fs.path.basename")
local list_dir_contents = require("utils.fs.list_dir_contents")

function Toolkit.new(opts)
  local self = setmetatable({}, Toolkit)

  local tool_path = vim.fn.stdpath("config") .. "/lua/components/chat/tools"
  local tool_files = list_dir_contents(tool_path)

  local tools = {}
  local tool_names = {}
  local tool_schemas = {}

  for _, file in ipairs(tool_files) do
    local tool = require("components.chat.tools." .. basename(file[1], true))
    if tool._enabled then
      tools[tool.name] = tool
      table.insert(tool_names, tool.name)
      table.insert(tool_schemas, tool.schema)
    end
  end

  function self.list()
    return tool_schemas
  end

  function self.exec(name, args, engine, cb)
    return tools[name].exec(args, engine, cb)
  end

  return self
end

return Toolkit
