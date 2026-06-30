local util = require("lspconfig.util")

local M = {}

local SOLUTION_BY_OS = {
  Linux = "LinuxSolution.sln",
  Darwin = "MacSolution.sln",
  Windows = "WindowsSolution.sln",
}

local PLATFORM_SUFFIX = {
  Linux = "Linux",
  Darwin = "Mac",
  Windows = "Windows",
}

---@param start_path? string
---@return string?
function M.root(start_path)
  local path = start_path
    or (vim.api.nvim_buf_get_name(0) ~= "" and vim.api.nvim_buf_get_name(0) or vim.fn.getcwd())
  return util.root_pattern("*.sln")(path) or util.root_pattern("*.csproj")(path)
end

function M.solution_name()
  return SOLUTION_BY_OS[vim.uv.os_uname().sysname] or "WindowsSolution.sln"
end

---@param start_path? string
---@return string?
function M.solution_path(start_path)
  local root = M.root(start_path)
  if not root then
    return nil
  end
  local sln = root .. "/" .. M.solution_name()
  if vim.fn.filereadable(sln) == 1 then
    return sln
  end
  return nil
end

---@param configuration? string
---@return string?
function M.client_bin_dir(configuration)
  configuration = configuration or "Debug"
  local root = M.root()
  if not root then
    return nil
  end
  local suffix = PLATFORM_SUFFIX[vim.uv.os_uname().sysname] or "Windows"
  return root .. "/Barotrauma/bin/" .. configuration .. suffix .. "/net8.0"
end

return M
