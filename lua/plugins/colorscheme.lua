return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("util.dots_theme").startup()
      end,
    },
  },
}
