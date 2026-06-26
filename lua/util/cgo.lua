local M = {}

local pending = {} ---@type table<string, integer>

---@param path string
---@return string?
local function go_mod_root(path)
  if path == "" then
    return nil
  end
  return vim.fs.root(path, { "go.mod", "go.work" })
end

---@param bufnr integer
---@return boolean
function M.has_cgo_import(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:match('import%s+"C"') or line:match('import%s+C%s+"') then
      return true
    end
  end
  return false
end

---@param root string
---@return string[]
function M.find_cgo_go_files(root)
  local obj = vim.system({
    "rg",
    "-l",
    [[import\s+"C"]],
    root,
    "--glob",
    "*.go",
    "--glob",
    "!vendor/**",
  }, { text = true }):wait()
  if obj.code ~= 0 or not obj.stdout or obj.stdout == "" then
    return {}
  end
  return vim.split(vim.trim(obj.stdout), "\n", { plain = true })
end

---@param path string
---@return boolean ok
---@return string? err
function M.run_go_tool_cgo_path(path)
  if path == "" then
    return false, "empty path"
  end

  local dir = vim.fn.fnamemodify(path, ":h")
  local base = vim.fn.fnamemodify(path, ":t")
  local obj = vim.system({ "go", "tool", "cgo", base }, {
    cwd = dir,
    env = vim.fn.environ(),
    text = true,
  }):wait()

  if obj.code ~= 0 then
    local err = vim.trim((obj.stderr or "") .. "\n" .. (obj.stdout or ""))
    if err == "" then
      err = "go tool cgo failed"
    end
    return false, err
  end

  return true
end

---@param bufnr integer
---@return boolean ok
---@return string? err
function M.run_go_tool_cgo(bufnr)
  return M.run_go_tool_cgo_path(vim.api.nvim_buf_get_name(bufnr))
end

---@param bufnr integer
function M.resync_gopls(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
  if #clients == 0 then
    return
  end

  local ids = vim.tbl_map(function(c)
    return c.id
  end, clients)

  for _, id in ipairs(ids) do
    pcall(vim.lsp.buf_detach_client, bufnr, id)
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    for _, id in ipairs(ids) do
      if vim.lsp.get_client_by_id(id) then
        pcall(vim.lsp.buf_attach_client, bufnr, id)
      end
    end
  end)
end

---@param uri string
---@param bufnr? integer
---@param on_done? fun(err?: string)
---@return boolean
function M.regenerate_uri(uri, bufnr, on_done)
  local clients = vim.lsp.get_clients({ name = "gopls", bufnr = bufnr })
  if #clients == 0 then
    clients = vim.lsp.get_clients({ name = "gopls" })
  end
  if #clients == 0 then
    if on_done then
      on_done("gopls is not running")
    end
    return false
  end

  local client = clients[1]
  local exec_bufnr = bufnr
  if exec_bufnr == nil or #vim.lsp.get_clients({ name = "gopls", bufnr = exec_bufnr }) == 0 then
    for attached in pairs(client.attached_buffers or {}) do
      exec_bufnr = attached
      break
    end
  end
  if exec_bufnr == nil then
    if on_done then
      on_done("no gopls buffer available")
    end
    return false
  end

  client:exec_cmd({
    title = "Regenerate cgo",
    command = "gopls.regenerate_cgo",
    arguments = { { URI = uri } },
  }, { bufnr = exec_bufnr }, function(err, _result, _ctx)
    if on_done then
      on_done(err and (err.message or vim.inspect(err)) or nil)
    end
  end)

  return true
end

---@param bufnr integer
---@param opts? { notify?: boolean }
---@return boolean
function M.regenerate(bufnr, opts)
  opts = opts or {}
  local notify = opts.notify ~= false

  if not M.has_cgo_import(bufnr) then
    if notify then
      vim.notify('No import "C" in this buffer', vim.log.levels.WARN)
    end
    return false
  end

  local ok, err = M.run_go_tool_cgo(bufnr)
  if not ok then
    if notify then
      vim.notify("go tool cgo failed:\n" .. (err or ""), vim.log.levels.ERROR)
    end
    return false
  end

  M.regenerate_uri(vim.uri_from_bufnr(bufnr), bufnr, function(gopls_err)
    M.resync_gopls(bufnr)
    if gopls_err and notify then
      vim.notify(
        "cgo regenerated with go tool cgo, but gopls reload failed:\n" .. gopls_err,
        vim.log.levels.WARN
      )
    elseif notify then
      vim.notify("Regenerated cgo definitions", vim.log.levels.INFO)
    end
  end)

  return true
end

---@param key string
---@param delay_ms integer
---@param fn fun()
function M.debounce(key, delay_ms, fn)
  pending[key] = (pending[key] or 0) + 1
  local seq = pending[key]
  vim.defer_fn(function()
    if pending[key] ~= seq then
      return
    end
    fn()
  end, delay_ms)
end

---@param root string
---@param delay_ms? integer
function M.schedule_module_regenerate(root, delay_ms)
  M.debounce("cgo:" .. root, delay_ms or 400, function()
    local files = M.find_cgo_go_files(root)
    if #files == 0 then
      return
    end
    for _, path in ipairs(files) do
      local ok, err = M.run_go_tool_cgo_path(path)
      if not ok then
        vim.notify("go tool cgo failed for " .. path .. ":\n" .. (err or ""), vim.log.levels.WARN)
      end
      local bufnr = vim.fn.bufnr(path)
      M.regenerate_uri(vim.uri_from_fname(path), bufnr > 0 and bufnr or nil, function(gopls_err)
        if bufnr > 0 then
          M.resync_gopls(bufnr)
        end
        if gopls_err then
          vim.notify("gopls cgo reload failed for " .. path .. ":\n" .. gopls_err, vim.log.levels.WARN)
        end
      end)
    end
  end)
end

---@param bufnr integer
---@param delay_ms? integer
function M.schedule_buf_regenerate(bufnr, delay_ms)
  if not M.has_cgo_import(bufnr) then
    return
  end
  M.debounce("cgo-buf:" .. bufnr, delay_ms or 1200, function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    M.regenerate(bufnr, { notify = false })
  end)
end

---@param bufnr integer
local function codelens_supported(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method("textDocument/codeLens") then
      return true
    end
  end
  return false
end

---@param bufnr integer
local function refresh_codelens(bufnr)
  if not codelens_supported(bufnr) then
    return
  end
  -- Neovim 0.12+: enable() is the supported API (refresh() is deprecated).
  vim.lsp.codelens.enable(true, { bufnr = bufnr })
end

---@param client vim.lsp.Client
---@param bufnr integer
function M.on_gopls_attach(client, bufnr)
  if vim.bo[bufnr].filetype ~= "go" then
    return
  end

  if M.has_cgo_import(bufnr) then
    refresh_codelens(bufnr)
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    buffer = bufnr,
    callback = function()
      if M.has_cgo_import(bufnr) then
        refresh_codelens(bufnr)
      end
    end,
  })

  vim.keymap.set("n", "<leader>gC", function()
    M.regenerate(bufnr)
  end, { buffer = bufnr, desc = "Regenerate cgo definitions" })

  vim.keymap.set("n", "<leader>cl", function()
    vim.lsp.codelens.run()
  end, { buffer = bufnr, desc = "Run code lens at cursor" })
end

function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup("config_gopls_cgo", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = { "*.h", "*.hpp", "*.hh", "*.c", "*.cc", "*.cpp" },
    callback = function(args)
      local path = vim.api.nvim_buf_get_name(args.buf)
      local root = go_mod_root(path)
      if root then
        M.schedule_module_regenerate(root)
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = { "*.go" },
    callback = function(args)
      M.schedule_buf_regenerate(args.buf)
    end,
  })
end

return M
