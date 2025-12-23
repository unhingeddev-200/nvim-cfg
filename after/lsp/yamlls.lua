return require("schema-companion").setup_client(
  require("schema-companion").adapters.yamlls.setup({
    sources = {
      -- your sources for the language server
      require("schema-companion").sources.matchers.kubernetes.setup({ version = "master" }),
      require("schema-companion").sources.lsp.setup(),
      require("schema-companion").sources.schemas.setup({
        {
          name = "Kubernetes master",
          uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json",
        },
      }),
    },
  }),
  {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yml" },
    settings = {
      yaml = {
        -- Enable format on save
        format = {
          enable = true,
        },
        -- Validation settings
        validate = true,
        completion = true,
        hover = true,
        -- Custom tags for Helm templates
        customTags = {

        },
      },
    },
    single_file_support = true,
  }
)
