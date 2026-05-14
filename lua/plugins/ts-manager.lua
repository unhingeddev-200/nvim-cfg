return {
  "romus204/tree-sitter-manager.nvim",
  dependencies = {}, -- tree-sitter CLI must be installed system-wide
  config = function()
    require("tree-sitter-manager").setup({
      -- Parsers for nvim-ts-autotag in .astro files (astro grammar depends on html + html_tags).
      ensure_installed = { "astro", "html", "html_tags" },
      -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
      -- auto_install = false, -- if enabled, install missing parsers when editing a new file
      -- highlight = true, -- treesitter highlighting is enabled by default
      languages = {
        gas = {
          install_info = {
            use_repo_queries = true,
            url = "file:///home/havok/Work/tree-sitter/tree-sitter-gas",
          },
        },
        slang = {
          install_info = {
            -- Builtin slang pins `revision`; deep-merge keeps it unless overridden.
            -- That checkout wins over your local master — use false to build clone HEAD.
            revision = false,
            use_repo_queries = true,
            url = "file:///home/havok/Work/repo/tree-sitter/tree-sitter-slang",
          },
        },
      },
      -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
      -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
    })

    -- nvim-ts-autotag needs an active parser before `>` runs; start() can run after FileType in some load orders.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "astro", "html" },
      callback = function(ev)
        vim.schedule(function()
          pcall(vim.treesitter.start, ev.buf)
        end)
      end,
      desc = "Tree-sitter attach (nvim-ts-autotag) for Astro/HTML",
    })

    -- slangd uses filetypes hlsl / shaderslang; parser is installed as "slang"
    vim.treesitter.language.register("slang", { "hlsl", "shaderslang" })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "hlsl", "shaderslang" },
      callback = function()
        pcall(vim.treesitter.start)
      end,
      desc = "Tree-sitter highlights (slang grammar) for HLSL / Shader Slang",
    })
  end,
}
