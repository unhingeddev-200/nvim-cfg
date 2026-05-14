return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Astro: wire @astrojs/ts-plugin into vtsls (LazyVim default TS server) so .ts/.tsx understand .astro imports.
    -- `location` may be any placeholder when the plugin is installed in the project node_modules (tsserver convention).
    local loc = vim.fn.stdpath("data") .. "/mason/packages/astro-language-server/node_modules/@astrojs/ts-plugin"
    if vim.fn.isdirectory(loc) ~= 1 then
      loc = "."
    end
    opts.servers.vtsls = opts.servers.vtsls or {}
    LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
      {
        name = "@astrojs/ts-plugin",
        location = loc,
        enableForWorkspaceTypeScriptVersions = true,
      },
    })

    opts.servers["*"] = opts.servers["*"] or {}
    opts.servers["*"].keys = opts.servers["*"].keys or {}
    vim.list_extend(opts.servers["*"].keys, {
      {
        "<c-k>",
        function()
          return require("blink.cmp").select_prev
        end,
        mode = "i",
        desc = "Select previous item",
      },
    })
  end,
}
