return {
  {
    dir = vim.env.ANODIZE_NVIM_DIR or vim.fn.expand("~/repos/Anodize.nvim"),
    name = "anodize",
    lazy = false,
    priority = 1000,
    opts = {
      source = "dots",
      transparent = true,
      terminal_colors = false,
      styles = {
        comments = {},
        keywords = {},
        functions = {},
        variables = {},
        floats = "normal",
        sidebars = "normal",
      },
      on_highlights = require("config.highlights.anodize").configure,
    },
    config = function(_, opts)
      require("util.dots_theme").install()
      require("anodize").setup(opts)
    end,
  },
}
