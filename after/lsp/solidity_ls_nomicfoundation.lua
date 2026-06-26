---@param root_dir? string
---@return string?
local function resolve_cmd(root_dir)
  if root_dir then
    local local_bin = vim.fs.joinpath(root_dir, "node_modules/.bin/nomicfoundation-solidity-language-server")
    if vim.fn.executable(local_bin) == 1 then
      return local_bin
    end
  end
  if vim.fn.executable("nomicfoundation-solidity-language-server") == 1 then
    return "nomicfoundation-solidity-language-server"
  end
  for _, p in
    ipairs(
      vim.fn.glob(
        vim.fn.expand("~/.local/share/mise/installs/node/*/bin/nomicfoundation-solidity-language-server"),
        false,
        true
      )
    )
  do
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  return nil
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = resolve_cmd(config.root_dir)
    if not cmd then
      vim.notify(
        "solidity_ls_nomicfoundation: binary not found (npm i -g @nomicfoundation/solidity-language-server, or add it as a project devDependency)",
        vim.log.levels.WARN
      )
      cmd = "nomicfoundation-solidity-language-server"
    end
    return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
  end,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then
      return on_dir(nil)
    end

    local markers = {
      "hardhat.config.js",
      "hardhat.config.ts",
      "foundry.toml",
      "remappings.txt",
      "truffle.js",
      "truffle-config.js",
      "ape-config.yaml",
      "package.json",
    }
    local found = vim.fs.find(markers, { path = fname, upward = true })[1]
    local root_dir = found and vim.fs.dirname(found)
    if not root_dir or not resolve_cmd(root_dir) then
      return on_dir(nil)
    end

    on_dir(root_dir)
  end,
}
