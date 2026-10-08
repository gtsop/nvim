local ChatController = {}
ChatController.__index = ChatController

local state = require("state")
local utils = require("utils")

local log = require("utils.log")
local Panel = require("utils.ui.panel")
local Ollama = require("utils.classes.ollama")

--local ollama = Ollama:new("gemma3:4b")
local ollama = Ollama:new()
--ollama:select_model("qwen2.5-coder:7b")
-- ollama:select_model("gemma3:4b")
ollama:select_model("qwen3.5:4b")

local isAsking

local engine = {
  {
    role = "system",
    content = [[
You are an IDE integrated coding assistant. You have the following tools at your disposal:

- reason
  - Description: Uses an LLM engine to reason about a query. Stores the response in a variable name taken from the `as` argument. When contructing the reasoning query you can use variables from other tool usages as part of the query
  - Arguments:
    - query: string - The query sent to the LLM. Make sure to include variables from other tools, if needed
    - as: string

- ask
  - Description: asks the user for some extra information
  - Arguments:
    - question: string - The question the user sees on their screen
    - as: string

- reply
  - Description: Replies to the user's interface
  - Arguments:
    - response: string

- list_project_files
  - Description: returns a list of the project's files
  - Arguments:
    - as: string - will contain the list of files

Construct a plan of tool usages in order to achieve the goal described by the user. Use as many tools as you need.

```
{
  plan: [ {name:"<tool_name>", args: { arg_name: arg_value }}, ... ]
}
```
When storing variables in `as` fields you can use them using the $ syntax.

Example: User asks "where are my string manipulation utilities?". You might construct the response with
```
{
  plan: [
    { name: "list_project_files", args: { as: "project_files" },
    { name: "reason", args: { query: "The user wants to know which of the following files probably contain string manipulation utilities: $project_files", as: "llm_response" },
    { name: "reply", args: { response: "$llm_response" },
  ]
}
```

YOU MUST ALWAYS USE THE REPLY TOOL AS THE FINAL TOOL (OR THE ONLY TOOL)
]],
  },
}

local chat_history = {
  {
    role = "system",
    content = "You are an IDE integrated coding assistant. When asked questions use very sort and to-the-point answers, assume the user very technivally knowledgable and only expand your answers when explicitly asked to. Even when expading, to be overly verbose",
  },
}

function ChatController.new(opts)
  local self = setmetatable({ ide = opts.ide, panel = opts.panel }, ChatController)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buffer, "filetype", "chat")
  vim.api.nvim_buf_set_option(buffer, "modifiable", true)

  local tools = {
    reason = function(args, vars, callback)
      ollama:prompt({
        messages = {
          {
            role = "system",
            content = "You are an IDE integrated coding assistant. When asked questions use very sort and to-the-point answers, assume the user very technivally knowledgable and only expand your answers when explicitly asked to. Even when expading, to be overly verbose",
          },
          {
            role = "user",
            content = self.replace_variables(args.query, vars),
          },
        },
        on_stream = function(response)
          vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(response, "\n"))
        end,
        on_end = function(response)
          vars[args.as] = response
          callback()
        end,
      })
    end,
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
    reply = function(args, vars, callback)
      local response = self.replace_variables(args.response, vars)
      table.insert(chat_history, {
        role = "assisntant",
        content = response,
      })
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(response, "\n"))
      callback()
    end,
    list_project_files = function(args, vars, callback)
      local project_dir = state.get_project_dir()
      local files = utils.list_dir_files(project_dir, true)

      vars[args.as] = table.concat(files, "\n")
      callback()
    end,
  }

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
    self.update_status("prompting...")
    local prompt = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

    table.insert(engine, {
      role = "user",
      content = prompt,
    })

    if isAsking then
      isAsking(prompt)
      return
    end

    ollama:prompt({
      messages = engine,
      format = "json",
      on_stream = function(response)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(response, "\n"))
      end,
      on_end = function(response)
        self.update_status("ok")
        local json = vim.json.decode(response)
        --log(json.plan)
        self.execute_plan(json.plan, {})
        --table.insert(chat_history, {
        --role = "assistant",
        --content = response,
        --})
      end,
    })

    --[[

    table.insert(chat_history, {
      role = "user",
      content = prompt,
    })

    ollama:prompt({
      messages = chat_history,
      on_stream = function(response)
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(response, "\n"))
      end,
      on_end = function(response)
        self.update_status("ok")
        table.insert(chat_history, {
          role = "assistant",
          content = response,
        })
      end,
    })

    ]]
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
    tools[tool_name](tool_args, variables, function()
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

  vim.api.nvim_create_user_command("ChatDebugHistory", self.print_history, { nargs = 0 })
  vim.api.nvim_create_user_command("ChatSelectModel", self.select_model, { nargs = 1 })
end

return ChatController
