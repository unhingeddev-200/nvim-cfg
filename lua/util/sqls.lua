local M = {}

---@param dsn string
---@param root_dir string
---@return string?
function M.sqlite_path_from_dsn(dsn, root_dir)
  dsn = vim.trim(dsn)
  local bare = dsn:match("^([^%?]+)")
  if not bare then
    return nil
  end

  local path = bare:match("^file://(/.+)$")
  if path then
    return path
  end

  path = bare:match("^file:(.+)$")
  if path then
    if vim.startswith(path, "./") then
      path = path:sub(3)
    end
    if path:sub(1, 1) == "/" then
      return path
    end
    return vim.fs.joinpath(root_dir, path)
  end

  if bare:sub(1, 1) == "/" then
    return bare
  end

  return vim.fs.joinpath(root_dir, bare)
end

---@param config_path string
---@return string[]
function M.sqlite_dsns_from_config(config_path)
  local ok, lines = pcall(vim.fn.readfile, config_path)
  if not ok or type(lines) ~= "table" then
    return {}
  end

  local dsns = {}
  local in_connections = false
  local driver = nil
  local dsn = nil

  local function flush()
    if driver == "sqlite3" and dsn then
      dsns[#dsns + 1] = dsn
    end
    driver = nil
    dsn = nil
  end

  for _, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$") or ""
    if trimmed == "" or trimmed:match("^#") then
      goto continue
    end

    if trimmed == "connections:" then
      in_connections = true
      goto continue
    end

    if not in_connections then
      goto continue
    end

    if line:match("^  %- ") then
      flush()
      goto continue
    end

    if line:match("^[%w_]+:") and not line:match("^  ") then
      flush()
      in_connections = false
      goto continue
    end

    local parsed_driver = trimmed:match("^driver:%s*(.+)$")
    if parsed_driver then
      driver = vim.trim(parsed_driver):gsub("^[\"']", ""):gsub("[\"']$", "")
    end

    local parsed_dsn = trimmed:match("^dataSourceName:%s*(.+)$")
    if parsed_dsn then
      dsn = vim.trim(parsed_dsn):gsub("^[\"']", ""):gsub("[\"']$", "")
    end

    ::continue::
  end

  flush()
  return dsns
end

---@param path string
---@return boolean
local function create_sqlite_db(path)
  local dir = vim.fs.dirname(path)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  if vim.uv.fs_stat(path) then
    return true
  end

  if vim.fn.executable("sqlite3") == 1 then
    local result = vim.system({ "sqlite3", path, "SELECT 1;" }):wait()
    if result.code == 0 then
      return true
    end
  end

  local result = vim.system({
    "python3",
    "-c",
    ("import sqlite3; sqlite3.connect(%q).close()"):format(path),
  }):wait()
  return result.code == 0
end

---@param config_path string
---@param root_dir string
function M.ensure_sqlite_databases(config_path, root_dir)
  for _, dsn in ipairs(M.sqlite_dsns_from_config(config_path)) do
    local path = M.sqlite_path_from_dsn(dsn, root_dir)
    if not path then
      vim.notify(("sqls: could not resolve sqlite path from %q"):format(dsn), vim.log.levels.WARN)
    elseif not create_sqlite_db(path) then
      vim.notify(("sqls: failed to create sqlite database at %s"):format(path), vim.log.levels.ERROR)
    end
  end
end

return M
