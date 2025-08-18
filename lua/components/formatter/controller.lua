local M = {}
M.__index = M

function M.new()
	local self = setmetatable({}, M)

	function self.get_lines()
		local buf = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		return table.concat(lines, "\n")
	end

	function self.get_filename()
		local buf = vim.api.nvim_get_current_buf()

		return vim.api.nvim_buf_get_name(buf)
	end

	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.md", "*.mdx", "*.json" },
		callback = function()
			local view = vim.fn.winsaveview()
			vim.cmd([[%!prettier --stdin-filepath %]])
			vim.fn.winrestview(view)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = { "*.lua" },
		callback = function()
			local view = vim.fn.winsaveview()
			local buf = vim.api.nvim_get_current_buf()

			local code = self.get_lines()
			local file = self.get_filename()

			local stdout = vim.fn.system({ "stylua", "--stdin-filepath", file, "-" }, code)
			local ok = vim.v.shell_error == 0

			if ok then
				local out = vim.split(stdout or "", "\n", { plain = true })
				if out[#out] == "" and code[#code] ~= "" then
					table.remove(out, #out)
				end
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
			end

			vim.fn.winrestview(view)
		end,
	})

	return self
end

return M
