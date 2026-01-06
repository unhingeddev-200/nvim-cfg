return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "bash app/install.sh",
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      -- Optional: Configure markdown preview settings
      vim.g.mkdp_auto_start = 0 -- Don't auto-start preview when opening markdown files
      vim.g.mkdp_auto_close = 1 -- Auto-close preview when switching away from markdown buffer
      vim.g.mkdp_refresh_slow = 0 -- Refresh on save or leaving insert mode
      vim.g.mkdp_command_for_global = 0 -- Only available in markdown buffers
      vim.g.mkdp_open_to_the_world = 0 -- Only accessible from localhost
      vim.g.mkdp_browser = "" -- Use default browser
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
    end,
  },
}
