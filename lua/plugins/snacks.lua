return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = {
        priority = 1,
        enabled = true,
        char = "│",
        only_scope = false,
        only_current = false,
        hl = {
          "SnacksIndent1",
          "SnacksIndent2",
          "SnacksIndent3",
          "SnacksIndent4",
          "SnacksIndent5",
          "SnacksIndent6",
          "SnacksIndent7",
          "SnacksIndent8",
        },
        animate = {
          enabled = vim.fn.has("nvim-0.10") == 1,
          style = "out",
          easing = "linear",
          duration = {
            step = 20,
            total = 200,
          },
        },
        scope = {
          enabled = true,
          priority = 200,
          char = "│",
          underline = false,
          only_current = false,
          hl = "SnacksIndentScope",
        },
        chunk = {
          enabled = false,
          priority = 200,
          only_current = false,
          hl = "SnacksIndentChunk",
          char = {
            corner_top = "┌",
            corner_bottom = "└",
            -- corner_top = "╭",
            -- corner_bottom = "╰",
            horizontal = "─",
            vertical = "│",
            arrow = ">",
          },
        },
        filter = function(buf)
          return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
        end,
      },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 4000,
      },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            hidden = true,
          },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { folds = { open = false } },
      words = { enabled = true },
    },
  },
}
