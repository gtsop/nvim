local Toolkit = {}
Toolkit.__index = Toolkit

local state = require("state")
local basename = require("utils.fs.path.basename")
local list_dir_contents = require("utils.fs.list_dir_contents")

function Toolkit.new(opts)
  local self = setmetatable({}, Toolkit)

  local tool_path = vim.fn.stdpath("config") .. "/lua/components/chat/tools"
  local tool_files = list_dir_contents(tool_path)
  local tool_names = {}
  local tool_descriptions = {}
  local tools = {}

  for _, file in ipairs(tool_files) do
    local tool = require("components.chat.tools." .. basename(file[1], true))
    if tool.on then
      local tool_name = tool.name()
      table.insert(tool_names, tool_name)
      table.insert(tool_descriptions, tool.desc())
      tools[tool_name] = tool
    end
  end

  function self.list()
    return table.concat(tool_names, ",")
  end

  function self.descriptions()
    return table.concat(tool_descriptions, "\n---\n")
  end

  function self.exec(name, args, vars, engine, cb)
    return tools[name].exec(args, vars, engine, cb)
  end

  return self
end

return Toolkit
