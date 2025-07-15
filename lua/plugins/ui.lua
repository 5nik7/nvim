local ui = require("util.ui")

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        width = 40,
        preset = {
          -- Used by the `header` section
          header = ui.banners.neovim.medium.block,
        },
        sections = {
          { section = "header", padding = 2 },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          -- { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
            icon = " ",
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
          -- function()
          --   local in_git = Snacks.git.get_root() ~= nil
          --   local cmds = {
          --     {
          --       icon = " ",
          --       title = "Git Status",
          --       cmd = "git --no-pager diff --stat -B -M -C",
          --       height = 10,
          --     },
          --   }
          --   return vim.tbl_map(function(cmd)
          --     return vim.tbl_extend("force", {
          --       section = "terminal",
          --       enabled = in_git,
          --       padding = 1,
          --       ttl = 5 * 60,
          --       indent = 3,
          --     }, cmd)
          --   end, cmds)
          -- end,
          -- { sections = "" },
          { section = "startup" },
        },
      },
    },
  },
}
