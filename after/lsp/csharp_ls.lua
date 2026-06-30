local barotrauma = require("util.barotrauma")
local util = require("lspconfig.util")

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    if vim.fn.executable("csharp-ls") ~= 1 then
      vim.notify("csharp-ls not found (`dotnet tool install -g csharp-ls`)", vim.log.levels.WARN)
    end

    local root = config.root_dir or config.cmd_cwd
    local args = { "csharp-ls" }
    local sln = barotrauma.solution_name()
    if root and vim.fn.filereadable(root .. "/" .. sln) == 1 then
      vim.list_extend(args, { "--solution", sln })
    end

    return vim.lsp.rpc.start(args, dispatchers, {
      cwd = root,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(
      util.root_pattern("*.sln")(fname)
        or util.root_pattern("*.slnx")(fname)
        or util.root_pattern("*.csproj")(fname)
    )
  end,
  filetypes = { "cs" },
  init_options = {
    AutomaticWorkspaceInit = true,
  },
  get_language_id = function(_, ft)
    if ft == "cs" then
      return "csharp"
    end
    return ft
  end,
}
