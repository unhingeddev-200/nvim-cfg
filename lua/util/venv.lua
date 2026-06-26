local M = {}

local ROOT_MARKERS = {
  "pyrightconfig.json",
  "pyproject.toml",
  "requirements.txt",
  ".git",
}

---@param bufnr? integer
---@return string?
function M.project_root(bufnr)
  bufnr = bufnr or 0
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname ~= "" then
    local root = vim.fs.root(fname, ROOT_MARKERS)
    if root then
      return root
    end
  end

  local found = vim.fs.find(ROOT_MARKERS, { path = vim.fn.getcwd(), upward = true })[1]
  if found then
    return vim.fs.dirname(found)
  end
end

---@param root string
---@param module string
---@return boolean
function M.has_module(root, module)
  local python = root .. "/.venv/bin/python3"
  if vim.fn.executable(python) ~= 1 then
    return false
  end
  local result = vim.system({ python, "-c", ("import %s"):format(module) }):wait()
  return result.code == 0
end

---@param name string
---@param root? string
---@return string?
function M.bin(name, root)
  local paths = {}

  if root then
    paths[#paths + 1] = root
  end

  local from_buf = M.project_root()
  if from_buf then
    paths[#paths + 1] = from_buf
  end

  local path = vim.fn.getcwd()
  while path and path ~= "" do
    paths[#paths + 1] = path
    local parent = vim.fs.dirname(path)
    if parent == path then
      break
    end
    path = parent
  end

  local seen = {}
  for _, dir in ipairs(paths) do
    if dir and not seen[dir] then
      seen[dir] = true
      local bin = dir .. "/.venv/bin/" .. name
      if vim.fn.executable(bin) == 1 then
        return bin
      end
    end
  end
end

return M
