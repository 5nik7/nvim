local ui = require("util.ui")
local header = ui.banners.neovim.dotlet
local header_width = 1
for _, line in ipairs(vim.split(header, "\n", { plain = true })) do
  header_width = math.max(header_width, vim.fn.strdisplaywidth(line))
end

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        width = header_width,
        rows = nil,
        col = nil,
        pane_gap = 0,
        autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        preset = {
          header = header,
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
