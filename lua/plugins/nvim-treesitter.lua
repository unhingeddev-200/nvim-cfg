-- LazyVim bundles nvim-treesitter; keep it off in favor of romus204/tree-sitter-manager.nvim
-- (see lua/plugins/ts-manager.lua). Parsers live under stdpath("data")/site/parser.
return {
  "nvim-treesitter/nvim-treesitter",
  enabled = false,
}
