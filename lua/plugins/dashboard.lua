local ui = require("util.ui")
-- local colors = require("catppuccin.palettes").get_palette()

-- local stats = require("lazy.stats").stats()

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        width = 29,
        rows = nil,
        col = nil,
        pane_gap = 0,
        autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
        preset = {
          -- pick = nil,
          -- keys = {
          --   { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          --   { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          --   { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          --   { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          --   {
          --     icon = " ",
          --     key = "c",
          --     desc = "Config",
          --     action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          --   },
          --   { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          --   { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          --   { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          --   { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          -- },
          -- Used by the `header` section
          header = ui.banners.neovim.tube,
        },
        -- formats = {
        -- key = function(item)
        --   return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        -- end,
        -- },
        formats = {
          file = function(item, ctx)
            local fname = vim.fn.fnamemodify(item.file, ":~")

            -- Shorten directory components first.
            if ctx.width and #fname > ctx.width then
              fname = vim.fn.pathshorten(fname)
            end

            -- If it is still too long, discard the directory rather than
            -- truncating the filename.
            if ctx.width and #fname > ctx.width then
              local file = vim.fn.fnamemodify(fname, ":t")
              fname = "…/" .. file
            end

            local dir, file = fname:match("^(.*)/(.+)$")

            return dir
                and {
                  { dir .. "/", hl = "dir" },
                  { file, hl = "file" },
                }
              or {
                { fname, hl = "file" },
              }
          end,
        },
        sections = {
          { section = "header", padding = 1 },
          { section = "keys", indent = 1, padding = 1 },
          {
            title = "Recent",
            cwd = false,
            limit = 5,
            section = "recent_files",
            indent = 1,
            padding = 1,
          },
          -- {
          --   icon = " ",
          --   title = "Git Status",
          --   section = "terminal",
          --   enabled = function()
          --     return Snacks.git.get_root() ~= nil
          --   end,
          --   cmd = "git status --short --branch --renames",
          --   height = 5,
          --   padding = 1,
          --   ttl = 5 * 60,
          --   indent = 3,
          -- },

          -- { title = "Recent ", file = vim.fn.fnamemodify(".", ":~"), indent = 0, padding = 0 },
          -- { section = "recent_files", cwd = true, limit = 8, indent = 0, padding = 1 },

          -- { icon = " ", title = "Projects", section = "projects", indent = 0, padding = 1 },

          -- { icon = "", title = "", file = vim.fn.fnamemodify(".", ":~"), indent = 0, padding = 1 },
          -- { section = "recent_files", cwd = false, limit = 10, indent = 0, padding = 1 },

          -- {
          --   section = "startup",
          --   padding = 1,
          --   icon = "",
          -- },
          -- {
          --   section = "terminal",
          --   cmd = "btry",
          --   height = 1,
          --   padding = 1,
          --   ttl = 3 * 60,
          --   indent = 0,
          -- },
        },
      },
    },
  },
}
