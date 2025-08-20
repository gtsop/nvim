local M = {}
M.__index = M

function M.new()
	local self = setmetatable({}, M)

	vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"
	vim.opt.completeopt = "menu,menuone,noinsert,popup"
	vim.opt.pumheight = 10

	function self.should_show_popup(char)
		local popup_visible = vim.fn.pumvisible() == 1
		local has_lsp = vim.o.omnifunc == "v:lua.vim.lsp.omnifunc"

		local col = vim.fn.col(".") - 1
		if col <= 0 then
			return false
		end

		local makese_sense_to_show = char:match("[%w_.]") ~= nil

		return not popup_visible and has_lsp and makese_sense_to_show
	end

	function self.show_autocomplete()
		local keys = vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true)
		vim.api.nvim_feedkeys(keys, "n", false)
	end

	vim.api.nvim_create_autocmd({ "InsertCharPre" }, {
		callback = function()
			if self.should_show_popup(vim.v.char) then
				self.show_autocomplete()
			end
		end,
	})

	vim.keymap.set("i", "<CR>", function()
		if vim.fn.pumvisible() == 1 then
			local sel = vim.fn.complete_info({ "selected" }).selected
			if sel ~= -1 then
				return vim.api.nvim_replace_termcodes("<C-y>", true, false, true) -- confirm
			else
				return vim.api.nvim_replace_termcodes("<C-e><CR>", true, false, true) -- close menu, newline
			end
		end
		return "\r" -- normal Enter
	end, { expr = true, desc = "Confirm completion only if selected" })

	--[[ Signature help
	vim.api.nvim_create_autocmd("InsertCharPre", {
		callback = function()
			local char = vim.v.char
			if char == "(" or char == "," then
				vim.defer_fn(function()
					vim.lsp.buf.signature_help()
				end, 50)
			end
		end,
	})
  ]]

	return self
end

return M
