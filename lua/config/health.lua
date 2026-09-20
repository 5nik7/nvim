local M = {}

function M.check()
  local platform = require("util.platform")
  local health = vim.health
  local detected = platform.detect()
  health.start("Portable configuration")
  health.info("Platform: " .. detected.name)
  health.info("Config: " .. vim.fn.stdpath("config"))
  health.info("Data: " .. vim.fn.stdpath("data"))
  health.info("Shell: " .. vim.o.shell)
  health.info("External tools: " .. (detected.termux and "native tools on PATH; Mason disabled" or "Mason and PATH"))
  if vim.fn.has("nvim-0.11.2") == 1 and jit then
    health.ok("Neovim >= 0.11.2 with LuaJIT")
  else
    health.error("Use Neovim >= 0.11.2 built with LuaJIT.")
  end
  if platform.has("git") then
    health.ok("Git: " .. vim.fn.exepath("git"))
  else
    health.error("Git is required for plugin installation and updates.")
  end

  health.start("Clipboard")
  -- Provider discovery does not copy or paste clipboard contents.
  local provider = vim.fn["provider#clipboard#Executable"]()
  if provider ~= "" then
    health.ok("Provider: " .. provider .. " (availability only; test a copy/paste round trip manually)")
  else
    health.warn("No clipboard provider detected. Internal registers still work; see README clipboard setup.")
  end

  health.start("Parser builds")
  if platform.can_build_parsers() then
    health.ok(
      "Compiler, tree-sitter, tar, and curl found. Check :checkhealth nvim-treesitter for version compatibility."
    )
  else
    health.warn(
      "Automatic parser builds skipped. Install a C compiler, tree-sitter CLI, tar, and curl; restart Neovim."
    )
  end
  health.info("LuaRocks: " .. (platform.has("luarocks") and "system executable" or "disabled; no Hererocks bootstrap"))

  health.start("Optional tools for enabled extras")
  local commands = {
    "rg",
    "fd",
    "lazygit",
    "node",
    "npm",
    "python3",
    "java",
    "go",
    "cargo",
    "zig",
    "nu",
    "lua-language-server",
    "stylua",
    "luacheck",
    "bash-language-server",
    "shfmt",
    "fish",
    "ruff",
    "basedpyright-langserver",
    "gopls",
    "goimports",
    "gofumpt",
    "golangci-lint",
    "rust-analyzer",
    "jdtls",
    "kotlin-language-server",
    "ktlint",
    "vtsls",
    "biome",
    "vscode-json-language-server",
    "yaml-language-server",
    "taplo",
    "marksman",
    "markdownlint-cli2",
    "tailwindcss-language-server",
    "zls",
    "prettierd",
    "prettier",
    "jq",
    "codelldb",
    "kotlin-debug-adapter",
  }
  for _, command in ipairs(commands) do
    local path = platform.tool(command)
    if path then
      health.ok(command .. ": " .. path)
    else
      health.warn(command .. " unavailable; install only if needed for your workflow (see README).")
    end
  end
  for name, command in pairs(require("util.tools").missing_servers) do
    health.warn(name .. " skipped: " .. command .. " is not on PATH. Install it and restart Neovim.")
  end
end

return M
