return {
  "folke/noice.nvim",
  ---@param opts NoiceConfig
  opts = function(_, opts)
    --- Skip noisy work-done progress / window messages from some servers (e.g. "Spawning language server…").
    --- Insert at the front so they match before the default LSP progress route.
    table.insert(opts.routes, 1, {
      filter = {
        any = {
          { event = "lsp", kind = "progress", find = "[Ss]pawning" },
          { event = "lsp", kind = "message", find = "[Ss]pawning" },
        },
      },
      opts = { skip = true },
    })
    return opts
  end,
}
