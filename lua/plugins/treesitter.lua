return {
  { "fei6409/log-highlight.nvim", event = "BufRead *.log", opts = {} },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "css",
        "gitcommit",
        "gitignore",
        "go",
        "graphql",
        "http",
        "just",
        "meson",
        "ninja",
        "php",
        "scss",
      })
    end,
  },
}
