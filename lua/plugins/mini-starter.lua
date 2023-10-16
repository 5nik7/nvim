-- start screen
return {
  -- disable alpha
  { "goolord/alpha-nvim", enabled = false },
  { "nvimdev/dashboard-nvim", enabled = false },

  -- enable mini.starter
  {
    "echasnovski/mini.starter",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function()
      local logo = [[
   ╔══╗╔══╗╔═════╗╔══════██╗   ██╗██╗██╗╔═══╗╔═══╗
   ║  \║  ║║  ╔══╝║  ╔═╗ ██║   ██║██║██║║   \/   ║
   ║   \  ║║  ╚══╗║  ║ ║ ██║   ██║██║██║║  \  /  ║
   ║  \   ║║  ╔══╝║  ║ ║ ╚██╗ ██╔╝██║██║║  ║\/║  ║
   ║  ║\  ║║  ╚══╗║  ╚═╝  ║████╔╝ ██║██║║  ║  ║  ║
   ╚══╝╚══╝╚═════╝╚═══════╝╚═══╝  ╚═╝╚═╝╚══╝  ╚══╝
]]
      local pad = string.rep(" ", 20)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")
      --stylua: ignore
      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          new_section("Find file",       "Telescope find_files",                                   "Telescope"),
          new_section("Recent files",    "Telescope oldfiles",                                     "Telescope"),
          new_section("Grep text",       "Telescope live_grep",                                    "Telescope"),
          new_section("Config",          "lua require('lazyvim.util').telescope.config_files()()", "Config"),
          new_section("Extras",          "LazyExtras",                                             "Config"),
          new_section("Lazy",            "Lazy",                                                   "Config"),
          new_section("New file",        "ene | startinsert",                                      "Built-in"),
          new_section("Quit",            "qa",                                                     "Built-in"),
          new_section("Session restore", [[lua require("persistence").load()]],                    "Session"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local pad_footer = string.rep(" ", 8)
          starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(starter.refresh)
        end,
      })
    end,
  },
}
