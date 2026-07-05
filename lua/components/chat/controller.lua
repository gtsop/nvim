local ChatController = {}
ChatController.__index = ChatController

local Panel = require("utils.ui.panel")
local Ollama = require("utils.classes.ollama")

--local ollama = Ollama:new("gemma3:4b")
local ollama = Ollama:new()
--ollama:select_model("qwen2.5-coder:7b")
ollama:select_model("gemma3:4b")

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
        --vim.print({
        -- messages = #chat_history,
        --  prompt_eval_count = ollama.prompt_eval_count,
        --  usage = ollama:get_context_usage(),
        --})
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
