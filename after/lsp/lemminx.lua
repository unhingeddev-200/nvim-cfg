---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    if vim.fn.executable("lemminx") ~= 1 then
      vim.notify("lemminx not found (install from AUR: `yay -S lemminx`)", vim.log.levels.WARN)
    end
    return vim.lsp.rpc.start({ "lemminx" }, dispatchers, {
      cwd = config.root_dir or config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
  root_markers = { ".git" },
}
