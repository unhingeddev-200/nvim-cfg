return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      -- Disable treesitter highlighting in picker to avoid query errors
      formatters = {
        file = {
          filename_first = true,
        },
      },
      -- Disable syntax highlighting which causes the treesitter query errors
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
          },
        },
      },
      -- Disable treesitter-based highlighting
      previewers = {
        file = {
          treesitter = false, -- Disable treesitter in file preview
        },
      },
    },
  },
}
