local ui = require("util.ui")

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        width = 28,
        rows = nil,
        col = nil,
        pane_gap = 0,
        autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        preset = {
          header = ui.banners.neovim.tube,
        },
        formats = {
          file = ui.format_dashboard_file,
        },
        sections = {
          require("util.dashboard_gradient").section,
          { section = "keys", indent = 1, padding = 1 },
          {
            title = "Recent",
            cwd = false,
            limit = 5,
            section = "recent_files",
            indent = 1,
            padding = 1,
          },
        },
      },
    },
  },
}
