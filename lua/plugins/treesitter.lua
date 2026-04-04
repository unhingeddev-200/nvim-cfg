return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure markdown parsers are installed (MDX can use markdown highlighting)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "markdown",
        "markdown_inline",
        "html",
        "javascript",
        "typescript",
        "tsx",
      })

      vim.treesitter.language.register("gas", "gas")
      opts.local_parsers = opts.local_parsers or {}

      opts.local_parsers.gas = {
        source = {
          type = "local",
          path = "/home/havok/Work/tree-sitter/tree-sitter-gas",
          queries_path = "queries",
        },
        filetypes = { "asm", "s", "S", "gas" },
      }

      return opts
    end,
    init = function()
      vim.filetype.add({
        extension = {
          gas = "gas",
        },
      })
    end,
  },
}
