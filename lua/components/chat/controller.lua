local ChatController = {}
ChatController.__index = ChatController

local Toolkit = require("components.chat.toolkit")

local log = require("utils.log")
local Panel = require("utils.ui.panel")
local Ollama = require("utils.classes.ollama")
local input = require("input")

local toolkit = Toolkit:new()
local ollama = Ollama:new({ tools = toolkit.list() })

--ollama:select_model("gemma4:31b")
--ollama:select_model("qwen2.5-coder:3b")
--ollama:select_model("qwen3.5:9b")
--ollama:select_model("qwen3:4b")
--ollama:select_model("gemma3:1b")
ollama:select_model("lfm2.5:latest")

local isAsking

local plans = {}

local engine_prompt = {
  role = "system",
  content = [[
You are an IDE integrated coding assistant.
When asked reply with concice answers, don't be overly verbose unless explicitly asked so by the user
When writting code, refrain from writting too many explanatory comments
]],
}

local chat_history = { engine_prompt }

function ChatController.new(opts)
  local self = setmetatable({ ide = opts.ide, panel = opts.panel }, ChatController)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buffer, "chat")
  vim.api.nvim_buf_set_option(buffer, "filetype", "chat")
  vim.api.nvim_buf_set_option(buffer, "modifiable", true)

  local engine = { ollama = ollama }
  function engine.replace_variables(str, vars)
    return self.replace_variables(str, vars)
  end
  function engine.print_text(str)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(str, "\n"))
  end
  function engine.append_chat_history(obj)
    table.insert(chat_history, obj)
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
    self.update_status("reasoning...")
    local prompt = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    table.insert(chat_history, {
      role = "user",
      content = prompt,
    })
    ollama:prompt({
      messages = chat_history,
      on_stream = function(response)
        engine.print_text(response)
      end,
      on_end = function(response)
        self.update_status("ok")
        engine.print_text(response)
      end,
      on_call_tool = function(tool_name, tool_args)
        self.update_status("[tool][start] " .. tool_name)
        local result = toolkit.exec(tool_name, tool_args, self.ide)
        self.update_status("[tool][end] " .. tool_name)
        return result
      end,
    })
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

  function self.update_status(status)
    status = status or ""
    vim.wo.winbar = "("
      .. ollama:get_model()
      .. " - "
      .. string.format("%.1f%%%%", ollama:get_context_usage())
      .. " ): "
      .. status
  end

  function self.show_model_selection_ui()
    ollama:fetch_models(function(models)
      vim.ui.select(models, {
        prompt = "Select model:",
      }, function(choice)
        if choice then
          ollama:select_model(choice)
        end
      end)
    end)
  end

  vim.api.nvim_create_user_command("ChatDebugHistory", self.print_history, { nargs = 0 })
  vim.api.nvim_create_user_command("ChatSelectModel", self.show_model_selection_ui, { nargs = 0 })
end

return ChatController
