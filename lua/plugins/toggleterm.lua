local drip = require("util.dream").drip

return {
  {
    "akinsho/toggleterm.nvim",
    config = {
      size = 20,
      open_mapping = [[<leader>tt]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = false,
      shading_factor = 0,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      -- direction = 'vertical' | 'horizontal' | 'tab' | 'float',
      direction = "horizontal",
      auto_scroll = true,
      highlights = {
        Normal = {
          guibg = drip.bg_dark,
        },
        FloatBorder = {
          guifg = drip.bg_dark,
        },
      },
      close_on_exit = true,
      float_opts = {
        border = "single",
        -- winblend = 0,
        -- highlights = {
        --   border = "Normal",
        --   background = "Normal",
        -- },
      },
    },
  },
}
