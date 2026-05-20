local ChatController = {}
ChatController.__index = ChatController

local Panel = require("utils.ui.panel")

function ChatController.new(opts)
  local self = setmetatable({ ide = opts.ide }, ChatController)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buffer, "filetype", "chat")
  vim.api.nvim_buf_set_option(buffer, "modifiable", true)

  local panel = Panel:new({
    name = "chat",
    on_enter = function() end,
    on_leave = function() end,
    on_close = function() end,
    position = "bottom",
  })

  function self.show()
    panel:open({ buffer = buffer })
  end

  vim.api.nvim_create_user_command("ChatShow", self.show, { nargs = 0 })

  vim.keymap.set("n", "<CR>", function()
    vim.print("Sending text to chat")
    local lines = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    ask_llm(lines, function(response)
      vim.print(response)
    end)
  end, {
    buffer = buffer,
  })
end

function ask_llm(prompt, callback)
  vim.fn.jobstart({
    "curl",
    "-s",
    "http://localhost:11434/api/chat",
    "-d",
    vim.fn.json_encode({
      model = "gemma3:4b",
      stream = false,
      messages = {
        {
          role = "user",
          content = prompt,
        },
      },
    }),
    "-H",
    "Content-Type: application/json",
  }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local response = vim.fn.json_decode(table.concat(data, "\n"))
      local answer = response.message.content
      callback(answer)
    end,
  })
end

return ChatController
