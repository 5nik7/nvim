-- Load only the selected family. Lazy installs declared dependencies normally.
return {
  { "folke/tokyonight.nvim", lazy = true, opts = { transparent = true, terminal_colors = false } },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = { styles = { transparency = true }, enable = { terminal = false } },
  },
  { "rebelot/kanagawa.nvim", lazy = true, opts = { transparent = true, terminalColors = false } },
  { "ellisonleao/gruvbox.nvim", lazy = true, opts = { transparent_mode = true, terminal_colors = false } },
  { "uZer/pywal16.nvim", lazy = true },
}
