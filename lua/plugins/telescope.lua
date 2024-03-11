return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    opts = {
      defaults = {
        -- layout_strategy = "horizontal",
        layout_config = { prompt_position = "bottom", preview_width = 0.6, width = 0.7, height = 0.7 },
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        -- sorting_strategy = "ascending",
        -- winblend = 0,
        -- winblend = 100, (full transparency)
        winblend = 0,
        prompt_prefix = "  ",
        selection_caret = " ",
      },
    },
  },
}
