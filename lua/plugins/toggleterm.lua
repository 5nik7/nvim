return {
  {
    "akinsho/toggleterm.nvim",
    config = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      -- direction = 'vertical' | 'horizontal' | 'tab' | 'float',
      direction = "horizontal",
      auto_scroll = true,
      highlights = {
        Normal = {
          guibg = "#181825",
        },
        FloatBorder = {
          guifg = "#313244",
        },
      },
      close_on_exit = true,
      float_opts = {
        border = "single",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },
}
