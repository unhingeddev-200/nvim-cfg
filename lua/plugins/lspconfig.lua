return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      keys = {
        {
          "<c-k>",
          function()
            return require("blink.cmp").select_prev
          end,
          mode = "i",
          desc = "Select previous item",
        },
      },
    },
  },
}
