-- Shared helpers + security policy for chat tools. Not a tool itself.
--
-- Hard requirements:
-- 1) Every filesystem path must resolve under the project root (symlink-aware).
-- 2) No LLM-driven shell. Processes may only run as fixed argv lists through
--    run_argv(), with an allowlisted binary basename (never bash/sh -c / strings).
local state = require("state")

local M = {
  _enabled = false,
}

M.IGNORE_DIRS = {
  ".git",
  "node_modules",
  "dist",
  "build",
  "coverage",
  ".venv",
  "__pycache__",
  ".pytest_cache",
}

M.DEFAULTS = {
  list_limit = 100,
  grep_limit = 50,
  read_limit = 200,
  max_bytes = 32000,
  outline_max = 80,
  context_before = 20,
  context_after = 20,
  git_log_limit = 10,
  process_timeout_ms = 30000,
}

-- Only these basenames may be executed. No shells, interpreters, or env wrappers.
M.ALLOWED_BINARIES = {
  git = true,
  rg = true,
  grep = true,
}

local FORBIDDEN_BINARIES = {
  bash = true,
  sh = true,
  zsh = true,
  fish = true,
  dash = true,
  env = true,
  sudo = true,
  xargs = true,
  busybox = true,
}

local function uv_realpath(path)
  if not path or path == "" then
    return nil
  end
  local real = vim.uv.fs_realpath(path)
  if real then
    return vim.fn.simplify(real)
  end
  return nil
end

function M.project_root()
  local root = vim.fn.simplify(state.get_project_dir())
  return uv_realpath(root) or root
end

function M.normalize(path)
  if not path or path == "" then
    return nil
  end
  if path:find("\0", 1, true) then
    return nil
  end
  return vim.fn.simplify(vim.fn.expand(path))
end

local function starts_with_root(absolute, root)
  if absolute == root then
    return true
  end
  return absolute:find(root .. "/", 1, true) == 1
end

--- True if absolute path (already normalized/realpath'd) is under project root.
function M.is_under_project(path)
  local absolute = M.normalize(path)
  if not absolute then
    return false
  end
  local root = M.project_root()
  local real = uv_realpath(absolute)
  if real then
    return starts_with_root(real, root)
  end

  -- Non-existent path: ensure lexical path is under root AND the longest
  -- existing ancestor realpath stays under root (blocks symlink escapes).
  if not starts_with_root(absolute, root) then
    return false
  end

  local cur = absolute
  while cur and cur ~= "" and cur ~= "/" do
    local ancestor = uv_realpath(cur)
    if ancestor then
      return starts_with_root(ancestor, root)
    end
    local parent = vim.fn.fnamemodify(cur, ":h")
    if parent == cur then
      break
    end
    cur = parent
  end

  return starts_with_root(absolute, root)
end

--- Resolve a path for tool use. Returns abs path under project, or nil, err.
--- opts.must_exist: require an existing readable file/dir after resolution.
function M.resolve_project_path(path, opts)
  opts = opts or {}
  if not path or path == "" then
    return nil, "SecurityError: path is required"
  end
  if type(path) ~= "string" or path:find("\0", 1, true) then
    return nil, "SecurityError: invalid path"
  end

  local absolute
  if path:sub(1, 1) == "/" then
    absolute = M.normalize(path)
  else
    absolute = M.normalize(M.project_root() .. "/" .. path)
  end

  if not absolute then
    return nil, "SecurityError: invalid path"
  end

  if not M.is_under_project(absolute) then
    return nil, "SecurityError: path is outside the project"
  end

  local real = uv_realpath(absolute)
  if real then
    if not starts_with_root(real, M.project_root()) then
      return nil, "SecurityError: path resolves outside the project"
    end
    absolute = real
  end

  if opts.must_exist then
    if vim.fn.filereadable(absolute) ~= 1 and vim.fn.isdirectory(absolute) == 0 then
      return nil, "ArgError: path does not exist"
    end
  end

  return absolute, nil
end

function M.require_under_project(path)
  local resolved, err = M.resolve_project_path(path)
  if err then
    return nil, err
  end
  return resolved, nil
end

function M.relativize(path)
  local absolute = M.normalize(path)
  if not absolute then
    return path
  end
  local root = M.project_root()
  local real = uv_realpath(absolute) or absolute
  if real == root then
    return "."
  end
  local prefix = root .. "/"
  if real:find(prefix, 1, true) == 1 then
    return real:sub(#prefix + 1)
  end
  return absolute
end

--- Paginate a list. offset is 0-based. Returns slice, total, remaining.
function M.paginate(list, offset, limit)
  offset = tonumber(offset) or 0
  limit = tonumber(limit) or M.DEFAULTS.list_limit
  if offset < 0 then
    offset = 0
  end
  if limit < 1 then
    limit = M.DEFAULTS.list_limit
  end

  local total = #list
  local start_i = offset + 1
  local end_i = math.min(offset + limit, total)
  local slice = {}
  if start_i <= total then
    for i = start_i, end_i do
      table.insert(slice, list[i])
    end
  end
  local remaining = math.max(0, total - end_i)
  return slice, total, remaining
end

function M.truncate_text(s, max_bytes)
  max_bytes = tonumber(max_bytes) or M.DEFAULTS.max_bytes
  if not s then
    return ""
  end
  if #s <= max_bytes then
    return s
  end
  return s:sub(1, max_bytes) .. string.format("\n... truncated (%d more bytes)", #s - max_bytes)
end

function M.format_lines(lines, start_line)
  start_line = start_line or 1
  local out = {}
  for i, line in ipairs(lines) do
    table.insert(out, string.format("%d|%s", start_line + i - 1, line))
  end
  return table.concat(out, "\n")
end

function M.match_glob(path, glob)
  if not glob or glob == "" then
    return true
  end
  local pattern = "^"
    .. glob:gsub("([%^%$%(%)%%%.%[%]%+%-%])", "%%%1"):gsub("%*", ".*"):gsub("%?", ".")
    .. "$"
  return path:match(pattern) ~= nil
end

function M.tonumber_arg(v, default)
  if v == nil or v == "" then
    return default
  end
  return tonumber(v) or default
end

function M.truthy(v)
  if v == nil then
    return false
  end
  if type(v) == "boolean" then
    return v
  end
  if type(v) == "string" then
    local lower = v:lower()
    return lower == "true" or lower == "1" or lower == "yes"
  end
  return not not v
end

function M.has_executable(name)
  local base = vim.fn.fnamemodify(name, ":t")
  if FORBIDDEN_BINARIES[base] or not M.ALLOWED_BINARIES[base] then
    return false
  end
  return vim.fn.executable(base) == 1
end

--------------------------------------------------------------------------
-- Safe filesystem ops (always re-check project jail)
--------------------------------------------------------------------------

function M.read_lines(path)
  local resolved, err = M.resolve_project_path(path, { must_exist = true })
  if err then
    return nil, err
  end
  if vim.fn.filereadable(resolved) ~= 1 then
    return nil, "ArgError: not a readable file"
  end
  local ok, lines = pcall(vim.fn.readfile, resolved)
  if not ok then
    return nil, "Error: failed to read " .. M.relativize(resolved)
  end
  return lines, nil
end

function M.write_lines(path, lines)
  local resolved, err = M.resolve_project_path(path)
  if err then
    return err
  end
  M.ensure_parent_dir(resolved)
  -- Re-check after ensuring parents (new dirs must stay in jail)
  if not M.is_under_project(resolved) then
    return "SecurityError: path is outside the project"
  end
  vim.fn.writefile(lines, resolved)
  return nil
end

function M.write_file(path, content)
  local resolved, err = M.resolve_project_path(path)
  if err then
    return nil, err
  end
  M.ensure_parent_dir(resolved)
  if not M.is_under_project(resolved) then
    return nil, "SecurityError: path is outside the project"
  end
  local file, open_err = io.open(resolved, "w")
  if not file then
    return nil, "Error: failed to open for write: " .. tostring(open_err)
  end
  file:write(content or "")
  file:close()
  return resolved, nil
end

function M.ensure_parent_dir(path)
  local resolved, err = M.resolve_project_path(path)
  if err then
    return err
  end
  local dir = vim.fn.fnamemodify(resolved, ":h")
  if dir == "" or dir == resolved then
    return nil
  end
  if not M.is_under_project(dir) then
    return "SecurityError: parent directory is outside the project"
  end
  if vim.fn.isdirectory(dir) == 0 then
    -- Creating parents: lexical path already jailed; mkdir under project only
    vim.fn.mkdir(dir, "p")
  end
  local dir_real = uv_realpath(dir)
  if dir_real and not starts_with_root(dir_real, M.project_root()) then
    return "SecurityError: parent directory resolves outside the project"
  end
  return nil
end

function M.delete_path(path)
  local resolved, err = M.resolve_project_path(path, { must_exist = true })
  if err then
    return err
  end
  if resolved == M.project_root() then
    return "SecurityError: refusing to delete project root"
  end
  local result = vim.fn.delete(resolved, "rf")
  if result ~= 0 then
    return "Error: failed to delete " .. M.relativize(resolved)
  end
  return nil
end

function M.rename_path(path, new_path)
  local src, err = M.resolve_project_path(path, { must_exist = true })
  if err then
    return nil, err
  end
  local dst, err2 = M.resolve_project_path(new_path)
  if err2 then
    return nil, err2
  end
  if src == M.project_root() or dst == M.project_root() then
    return nil, "SecurityError: refusing to rename project root"
  end
  local parent_err = M.ensure_parent_dir(dst)
  if parent_err then
    return nil, parent_err
  end
  if vim.fn.filereadable(dst) == 1 or vim.fn.isdirectory(dst) == 1 then
    return nil, "ArgError: destination already exists"
  end
  if vim.fn.rename(src, dst) ~= 0 then
    return nil, "Error: rename failed"
  end
  return dst, nil
end

function M.copy_file(path, new_path)
  local src, err = M.resolve_project_path(path, { must_exist = true })
  if err then
    return nil, err
  end
  if vim.fn.filereadable(src) ~= 1 then
    return nil, "ArgError: source must be a readable file"
  end
  local dst, err2 = M.resolve_project_path(new_path)
  if err2 then
    return nil, err2
  end
  if vim.fn.filereadable(dst) == 1 or vim.fn.isdirectory(dst) == 1 then
    return nil, "ArgError: destination already exists"
  end
  local parent_err = M.ensure_parent_dir(dst)
  if parent_err then
    return nil, parent_err
  end
  if vim.fn.writefile(vim.fn.readfile(src, "b"), dst, "b") ~= 0 then
    return nil, "Error: copy failed"
  end
  local dst_real = uv_realpath(dst)
  if not dst_real or not starts_with_root(dst_real, M.project_root()) then
    pcall(vim.fn.delete, dst)
    return nil, "SecurityError: copy landed outside the project"
  end
  return dst, nil
end

--------------------------------------------------------------------------
-- Safe process execution (argv only, allowlisted binaries, jailed cwd)
--------------------------------------------------------------------------

--- Run an allowlisted program with an argv table. Never accepts a shell string.
--- @param argv string[] executable + args (argv[1] must be an allowlisted basename)
--- @param opts? { cwd?: string, timeout_ms?: number, path_args?: string[] }
--- @return { code: number, stdout: string, stderr: string }|nil, string|nil err
function M.run_argv(argv, opts)
  opts = opts or {}

  if type(argv) == "string" then
    return nil, "SecurityError: shell command strings are forbidden; use argv lists"
  end
  if type(argv) ~= "table" or #argv < 1 then
    return nil, "SecurityError: argv must be a non-empty list"
  end
  for i, arg in ipairs(argv) do
    if type(arg) ~= "string" then
      return nil, string.format("SecurityError: argv[%d] must be a string", i)
    end
    if arg:find("\0", 1, true) then
      return nil, "SecurityError: argv contains NUL"
    end
  end

  local bin = vim.fn.fnamemodify(argv[1], ":t")
  if FORBIDDEN_BINARIES[bin] then
    return nil, "SecurityError: forbidden binary: " .. bin
  end
  if not M.ALLOWED_BINARIES[bin] then
    return nil, "SecurityError: binary not allowlisted: " .. bin
  end
  -- Force basename so callers cannot point at a trojan absolute path
  argv = vim.deepcopy(argv)
  argv[1] = bin

  local cwd = opts.cwd or M.project_root()
  local cwd_resolved, cwd_err = M.resolve_project_path(cwd, { must_exist = true })
  if cwd_err then
    return nil, cwd_err
  end
  if vim.fn.isdirectory(cwd_resolved) == 0 then
    return nil, "SecurityError: cwd must be a directory under the project"
  end

  -- Extra path args (already intended as filesystem paths) must be jailed
  if opts.path_args then
    for _, p in ipairs(opts.path_args) do
      local _, perr = M.resolve_project_path(p)
      if perr then
        return nil, perr
      end
    end
  end

  local result = vim.system(argv, {
    cwd = cwd_resolved,
    text = true,
    timeout = opts.timeout_ms or M.DEFAULTS.process_timeout_ms,
  }):wait()

  return {
    code = result.code or -1,
    stdout = result.stdout or "",
    stderr = result.stderr or "",
    signal = result.signal,
  }, nil
end

--- Convenience: git -C <project> <args...>. path_args are validated under jail.
function M.run_git(git_args, opts)
  opts = opts or {}
  local root = M.project_root()
  local argv = { "git", "-C", root }
  for _, a in ipairs(git_args) do
    table.insert(argv, a)
  end
  return M.run_argv(argv, {
    cwd = root,
    timeout_ms = opts.timeout_ms,
    path_args = opts.path_args,
  })
end

return M
