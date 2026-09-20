local platform = require("util.platform")
local tools = require("util.tools")
local termux = platform.detect().termux

-- This module is imported last, after extras have contributed dependencies/options.
return {
  { "mason-org/mason.nvim", enabled = not termux },
  { "mason-org/mason-lspconfig.nvim", enabled = not termux },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      tools.configure_servers(opts)
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      tools.guard_formatters(opts)
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      tools.guard_linters(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      if platform.can_build_parsers() then
        vim.env.CC = vim.env.CC or platform.compiler()
        require("nvim-treesitter").update(nil, { summary = true })
      end
    end,
    opts = function(_, opts)
      if platform.can_build_parsers() then
        vim.env.CC = vim.env.CC or platform.compiler()
      else
        -- Existing parsers still provide highlighting, folds, and indentation.
        opts.ensure_installed = {}
      end
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = { fuzzy = { implementation = "prefer_rust" } },
  },
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    build = not platform.detect().windows
        and platform.has("make")
        and platform.compiler() ~= nil
        and "make install_jsregexp"
      or false,
  },
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    cond = function()
      return platform.tool("jdtls") ~= nil and platform.has("java")
    end,
    opts = function(_, opts)
      -- Only inject Lombok when it actually exists (native jdtls need not use Mason).
      opts.cmd = { platform.tool("jdtls") or "jdtls" }
      local lombok = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "share", "jdtls", "lombok.jar")
      if not termux and vim.uv.fs_stat(lombok) then
        opts.cmd[#opts.cmd + 1] = "--jvm-arg=-javaagent:" .. lombok
      end
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    optional = true,
    cond = function()
      return platform.has("node") and platform.has("npm")
    end,
    -- Use Node on all platforms; the upstream Linux binary is not a Termux binary.
    build = function(plugin)
      local command = platform.detect().windows
          and { vim.env.COMSPEC or "cmd.exe", "/d", "/s", "/c", "npm install --omit=dev --ignore-scripts" }
        or { "npm", "install", "--omit=dev", "--ignore-scripts" }
      local result = vim.system(command, { cwd = vim.fs.joinpath(plugin.dir, "app"), text = true }):wait()
      assert(result.code == 0, result.stderr or "Markdown preview dependencies could not be installed")
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    optional = true,
    cond = function()
      return platform.tool("rust-analyzer") ~= nil
    end,
    config = function(_, opts)
      opts.server = opts.server or {}
      opts.server.cmd = { platform.tool("rust-analyzer") or "rust-analyzer" }
      local adapter, library = tools.codelldb()
      opts.dap = opts.dap or {}
      opts.dap.adapter = adapter and require("rustaceanvim.config").get_codelldb_adapter(adapter, library) or false
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts)
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/nvim-nio", "nvim-lua/plenary.nvim" },
    opts = function(_, opts)
      if not platform.tool("rust-analyzer") and opts.adapters then
        opts.adapters["rustaceanvim.neotest"] = nil
      end
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      if not platform.tool("kotlin-debug-adapter") then
        local dap = require("dap")
        dap.adapters.kotlin = nil
        dap.configurations.kotlin = nil
      end
    end,
  },
}
