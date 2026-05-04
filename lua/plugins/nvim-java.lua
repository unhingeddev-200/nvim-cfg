return {
  "nvim-java/nvim-java",
  config = function()
    require("java").setup({})
    vim.lsp.config("jdtls", {
      settings = {
        java = {
          inlayHints = {
            parameterNames = {
              enabled = "none", -- options: 'none', 'all', 'literals'
            },
          },
          project = {
            referencedLibraries = {
              paths = {
                "/home/havok/Android/Sdk/platforms/android-36/android.jar",
              },
            },
          },
          androidSupport = { enabled = true },
        },
      },
    })
    vim.lsp.enable("jdtls")
  end,
}
