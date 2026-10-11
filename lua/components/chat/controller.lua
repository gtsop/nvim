local ChatController = {}
ChatController.__index = ChatController

local Toolkit = require("components.chat.toolkit")

local log = require("utils.log")
local Panel = require("utils.ui.panel")
local Ollama = require("utils.classes.ollama")

--local ollama = Ollama:new("gemma3:4b")
local toolkit = Toolkit:new()
local ollama = Ollama:new()
--ollama:select_model("qwen2.5-coder:7b")
-- ollama:select_model("gemma3:4b")
-- ollama:select_model("qwen3.5:4b")
-- ollama:select_model("qwen3.5:9b")
-- ollama:select_model("deepseek-r1:latest")
ollama:select_model("qwen3-coder:30b")

--[[
- ask
  - Description: asks the user for some extra information
  - Arguments:
    - question: string - The question the user sees on their screen
    - as: string

- reply
  - Description: Replies to the user's interface
  - Arguments:
    - response: string
]]
local isAsking

local plans = {}

local engine_prompt = {
  role = "system",
  content = string.format(
    [[
You are an IDE integrated coding assistant. You have the following tools at your disposal:

%s

Your goal is to orchistrate a plan that when carried through will successfully respond to the user. Use as many tools as you need.
You must always finish by replying using "self.reply" or by contructing a new plan "self.plan"


## Plan structure

```
{
  "plan": [
     { "name":"<tool_name>", "args": { "<arg_name>": "<arg_value>" }},
     { "name":"<tool_name>", "args": { "<arg_name>": "<arg_value>" }},
  ]
}
```

Example plan: User asked "How much is one plus one?"
```
{
  "plan": [
     { "name":"user.reply", "args": { "response": "One plus one is 2" }},
  ]
}
```

## Using Variables


Most tools store the result in variables, you give the variable name in the `as` argument. You may use this variable in any follow up tool usage, by using the name of the variable prepended by a dollar sign $. Eg if you named the response of a tool "result" then in the next tool calls you can inject $result in the arguments.

VERY IMPORTANT!! Failing to use variables across tool calls will stop the propagation of data, resulting in information loss

Another example plan showcasing variable usage: User asks "where are my string manipulation utilities?".
```
{
  "plan": [
    { "name": "project.list_files", "args": { "as": "project_files" },
    { "name": "self.reason", "args": { "query": "Figure out which of these files probalby contain string manipulation utilities: $project_files", "as": "llm_response" },
    { "name": "user.reply", "args": { "response": "$llm_response" },
  ]
}
```

Example where multiple plans are necessary to carry out the task: User asks "what is the name of the utility that trims strings in my code?"
```
{
  "plan": [
    { "name": "project.list_files", "args": { "as": "project_files" },
    { "name": "self.reason", "args": { "query": "Figure out which of these files probalby contain string manipulation utilities: $project_files", "as": "llm_response" },
    { "name": "user.plan", "args": { "prompt": "Concstruct a new plan that reads the conentents of these files and finds the trimming utility", $llm_response" },
  ]
}
```

]],
    toolkit.descriptions()
  ),
}

vim.print(engine_prompt)

local chat_history = { engine_prompt }

function ChatController.new(opts)
  local self = setmetatable({ ide = opts.ide, panel = opts.panel }, ChatController)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buffer, "filetype", "chat")
  vim.api.nvim_buf_set_option(buffer, "modifiable", true)

  local tools = {
    ask = function(args, vars, callback)
      local query = self.replace_variables(args.question, vars)

      isAsking = function(response)
        table.insert(chat_history, {
          role = "user",
          content = response,
        })
        isAsking = nil
        vars[args.as] = response
        callback()
      end

      table.insert(chat_history, {
        role = "assistant",
        content = query,
      })

      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(query, "\n"))
    end,
  }

  local engine = {}
  function engine.replace_variables(str, vars)
    return self.replace_variables(str, vars)
  end
  function engine.print_text(str)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(str, "\n"))
  end
  function engine.append_chat_history(obj)
    table.insert(chat_history, obj)
  end
  function engine.plan(prompt)
    table.insert(chat_history, {
      role = "user",
      content = prompt,
    })
    ollama:prompt({
      messages = chat_history,
      format = "json",
      on_stream = function(response)
        engine.print_text(response)
      end,
      on_end = function(response)
        self.update_status("ok")
        local json = vim.json.decode(response)
        table.insert(plans, table.clone(json.plan))
        self.execute_plan(json.plan, {})
      end,
    })
  end

  local panel = self.panel:register("chat", {
    buffer = buffer,
    on_enter = function()
      vim.api.nvim_set_option_value("wrap", true, {
        win = self.panel.window,
      })
      self.panel:set_width(50)
    end,
    on_leave = function() end,
    on_close = function() end,
  })

  function self.show()
    self.panel:open("chat")
  end

  vim.api.nvim_create_user_command("ChatShow", self.show, { nargs = 0 })

  vim.keymap.set("n", "<CR>", function()
    self.update_status("planning...")
    local prompt = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    engine.plan(prompt)
  end, {
    buffer = buffer,
  })

  vim.keymap.set("n", "<C-c>", function()
    ollama:cancel()
  end, {
    buffer = buffer,
  })

  function self.print_history()
    vim.print(chat_history)
  end

  function self.select_model(params)
    ollama:select_model(params.args)
  end

  function self.update_status(status)
    status = status or ""
    vim.wo.winbar = "("
      .. ollama:get_model()
      .. " - "
      .. string.format("%.1f%%%%", ollama:get_context_usage())
      .. " ): "
      .. status
  end

  function self.execute_plan(plan, variables)
    if not plan then
      -- TODO reply with error
      return
    end

    if #plan == 0 then
      -- TODO reply with error
      return
    end

    local action = plan[1]

    local tool_name = action.name
    local tool_args = action.args

    self.update_status("Tool: " .. tool_name .. " (start)")
    tool_args.as = tool_args.as or action.as or "temp"
    toolkit.exec(tool_name, tool_args, variables, engine, function()
      self.update_status("Tool: " .. tool_name .. " (finish)")
      if #plan > 1 then
        table.remove(plan, 1)
        self.execute_plan(plan, variables)
      end
    end)
  end

  function self.replace_variables(str, vars)
    return (
      str:gsub("%$([%w_]+)", function(name)
        local value = vars[name]
        return value ~= nil and tostring(value) or "$" .. name
      end)
    )
  end

  function self.print_plan()
    vim.print(plans[#plans])
  end

  vim.api.nvim_create_user_command("ChatDebugHistory", self.print_history, { nargs = 0 })
  vim.api.nvim_create_user_command("ChatSelectModel", self.select_model, { nargs = 1 })
  vim.api.nvim_create_user_command("ChatPlan", self.print_plan, { nargs = 0 })
end

return ChatController
