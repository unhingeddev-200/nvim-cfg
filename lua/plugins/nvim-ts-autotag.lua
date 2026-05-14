-- Uses built-in vim.treesitter (no nvim-treesitter plugin). Parsers: tree-sitter-manager (:TSManager).
-- Load early: with `event = "LazyFile"` the FileType hook can register too late for the first buffer,
-- and InsertEnter `once` may be consumed by a non-HTML filetype so Astro never attaches.
return {
  "windwp/nvim-ts-autotag",
  lazy = false,
  opts = {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = true,
    },
  },
}
