local ui = require("util.ui")
local colors = require("catppuccin.palettes").get_palette()
-- local lazy_stats = require("lazy.stats").stats()
-- local ms = (math.floor(M.lazy_stats.startuptime * 100 + 0.5) / 100)

-- local stats = require("lazy.stats").stats()

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        width = 40,
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          -- Used by the `header` section
          header = ui.banners.neovim.medium.block,
        },
        sections = {
          { section = "header", padding = 1 },
          {
            section = "startup",
            padding = 1,
            icon = "", -- text = {
            --   { "Loaded ", hl = "footer" },
            --   { lazy_stats.loaded .. "/" .. lazy_stats.count, hl = "special" },
            --   { " plugins in ", hl = "footer" },
            --   { ms .. "ms", hl = "special" },
            -- },
          },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          {
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "git status --short --branch --renames",
            height = 3,
            padding = 1,
            ttl = 3 * 60,
            indent = 3,
          },
          -- {
          --   section = "terminal",
          --   cmd = "btry",
          --   height = 1,
          --   padding = 1,
          --   ttl = 3 * 60,
          --   indent = 3,
          -- },
        },
      },
    },
  },
}
