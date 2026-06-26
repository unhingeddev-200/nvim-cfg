local venv = require("util.venv")

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local root = config.root_dir or venv.project_root(config.bufnr)
    local cmd = venv.bin("mojo-lsp-server", root) or "mojo-lsp-server"
    if vim.fn.executable(cmd) ~= 1 then
      vim.notify(
        "mojo-lsp-server not found (install mojo in the project .venv or globally)",
        vim.log.levels.WARN
      )
    end
    return vim.lsp.rpc.start({ cmd }, dispatchers)
  end,
  root_markers = { "pyproject.toml", ".git" },
}
