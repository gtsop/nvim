local ChatController = {}
ChatController.__index = ChatController

local Toolkit = require("components.chat.toolkit")

local log = require("utils.log")
local Panel = require("utils.ui.panel")
local Ollama = require("utils.classes.ollama")

--local ollama = Ollama:new("gemma3:4b")
local toolkit = Toolkit:new()
local ollama = Ollama:new({ toolkit = toolkit })
--ollama:select_model("qwen2.5-coder:7b")
-- ollama:select_model("gemma3:4b")
-- ollama:select_model("qwen3.5:4b")
-- ollama:select_model("qwen3.5:9b")
-- ollama:select_model("deepseek-r1:latest")
ollama:select_model("qwen3-coder:30b")

local isAsking

local plans = {}

local engine_prompt = {
  role = "system",
  content = "You are an IDE integrated coding assistant",
}

local chat_history = { engine_prompt }

function ChatController.new(opts)
  local self = setmetatable({ ide = opts.ide, panel = opts.panel }, ChatController)

  local buffer = vim.api.nvim_create_buf(false, true)
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

  vim.api.nvim_create_user_command("ChatDebugHistory", self.print_history, { nargs = 0 })
  vim.api.nvim_create_user_command("ChatSelectModel", self.select_model, { nargs = 1 })
end

return ChatController
