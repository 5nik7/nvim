local platform = require("util.platform")
local M = {}

-- Kept for health reporting without enabling missing servers.
M.missing_servers = {}

function M.configure_servers(opts)
  local mason_servers
  if not platform.detect().termux and LazyVim and LazyVim.has and LazyVim.has("mason-lspconfig.nvim") then
    mason_servers = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
  end
  for name, value in pairs(opts.servers or {}) do
    if name ~= "*" and value ~= false then
      local server = value == true and {} or value
      opts.servers[name] = server
      if platform.detect().termux then
        server.mason = false
      end
      local native = server.mason == false or (mason_servers and not mason_servers[name])
      if server.enabled ~= false and native then
        local config = vim.lsp.config[name] or {}
        local cmd = server.cmd or config.cmd
        if type(cmd) == "table" and not platform.has(cmd[1]) then
          server.enabled = false
          M.missing_servers[name] = cmd[1]
        end
      end
    end
  end
end

function M.available_formatters(names, bufnr)
  local result = {}
  for key, value in pairs(names) do
    if type(key) ~= "number" then
      result[key] = value
    end
  end
  for _, name in ipairs(names) do
    if require("conform").get_formatter_info(name, bufnr).available then
      result[#result + 1] = name
    end
  end
  return result
end

function M.guard_formatters(opts)
  for ft, configured in pairs(opts.formatters_by_ft or {}) do
    opts.formatters_by_ft[ft] = function(bufnr)
      local names = type(configured) == "function" and configured(bufnr) or configured
      return M.available_formatters(names, bufnr)
    end
  end
end

function M.guard_linters(opts)
  local lint = require("lint")
  opts.linters = opts.linters or {}
  local seen = {}
  for _, names in pairs(opts.linters_by_ft or {}) do
    for _, name in ipairs(names) do
      if not seen[name] then
        seen[name] = true
        local base = lint.linters[name]
        if type(base) == "table" then
          local override = opts.linters[name] or {}
          local condition = override.condition or base.condition
          local command = override.cmd or base.cmd
          override.condition = function(ctx)
            if condition and not condition(ctx) then
              return false
            end
            local cmd = type(command) == "function" and command() or command
            return platform.has(cmd)
          end
          opts.linters[name] = override
        end
      end
    end
  end
end

function M.codelldb()
  local adapter = platform.tool("codelldb")
  if not adapter then
    return
  end
  local windows = platform.detect().windows
  local root = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "codelldb", "extension", "lldb")
  local library = vim.fs.joinpath(root, windows and "bin" or "lib", windows and "liblldb.dll" or "liblldb.so")
  if vim.uv.fs_stat(library) then
    return adapter, library
  end
end

return M
