return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Register MDX to use markdown tree-sitter parser
      vim.treesitter.language.register("markdown", "mdx")
      
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
      
      return opts
    end,
  },
}
