-- No plugins or personal configuration required: nvim --headless -u NONE -i NONE -l tests/portability.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
local platform = require("util.platform")
local tools = require("util.tools")
local original = {
  has = vim.fn.has,
  executable = vim.fn.executable,
  exepath = vim.fn.exepath,
  resolve = vim.fn.resolve,
  uname = vim.uv.os_uname,
}
local available, windows, wsl = {}, false, false
vim.env.TERMUX_VERSION, vim.env.PREFIX, vim.env.CC = nil, nil, nil
vim.fn.has = function(name)
  if name == "win32" then
    return windows and 1 or 0
  end
  if name == "wsl" then
    return wsl and 1 or 0
  end
  return original.has(name)
end
vim.fn.executable = function(cmd)
  return available[cmd] and 1 or 0
end
vim.fn.exepath = function(cmd)
  return available[cmd] and ("/tools with spaces/" .. cmd) or ""
end
vim.fn.resolve = function(path)
  return path
end
vim.uv.os_uname = function()
  return { sysname = windows and "Windows_NT" or "Linux" }
end

local count = 0
local function check(value, message)
  assert(value, message)
  count = count + 1
end

check(platform.detect().name == "Linux", "Linux detection")
check(platform.clipboard() == nil and platform.shell() == nil, "Linux defaults preserved")
vim.env.TERMUX_VERSION = "test"
check(platform.detect().termux, "Termux environment detection")
check(platform.clipboard() == nil, "missing Termux API")
available["termux-clipboard-set"] = true
check(platform.clipboard() == nil, "partial Termux API")
available["termux-clipboard-get"] = true
check(platform.clipboard().copy["+"][1] == "termux-clipboard-set", "Termux clipboard")
vim.env.TERMUX_VERSION = nil
vim.env.PREFIX = "/data/user/0/com.termux/files/usr"
check(platform.detect().termux, "Termux prefix detection")
vim.env.PREFIX = nil
wsl = true
check(platform.detect().wsl and platform.clipboard() == nil, "WSL without provider")
available["win32yank.exe"] = true
check(platform.clipboard().paste["+"][1] == "/tools with spaces/win32yank.exe", "WSL argv preserves spaces")
check(platform.clipboard().paste["+"][3] == "--lf", "WSL newline conversion")
wsl, windows = false, true
check(platform.detect().windows and platform.shell() == nil, "Windows default shell fallback")
available.powershell = true
check(platform.shell() == "powershell", "Windows PowerShell fallback")
available.pwsh = true
check(platform.shell() == "pwsh", "PowerShell Core preference")
windows = false

_G.LazyVim = { terminal = {
  setup = function()
    error("Unix shell must not be changed")
  end,
} }
vim.g.clipboard = { name = "custom" }
dofile("lua/config/options.lua")
check(vim.g.clipboard.name == "custom", "explicit clipboard survives options")
vim.g.clipboard = false
dofile("lua/config/options.lua")
check(vim.g.clipboard == false, "explicit default-provider setting preserved")
windows = true
available.pwsh = nil
LazyVim.terminal.setup = function()
  vim.o.shellcmdflag = "-Command $PSStyle.OutputRendering='plaintext';Write-Output"
end
dofile("lua/config/options.lua")
check(not vim.o.shellcmdflag:find("PSStyle", 1, true), "Windows PowerShell 5.1 flags avoid PSStyle")
windows = false

available = { cc = true, ["tree-sitter"] = true, tar = true, curl = true }
check(platform.can_build_parsers(), "parser prerequisites present")
available.cc = nil
check(not platform.can_build_parsers(), "parser compiler absent")

vim.env.TERMUX_VERSION = "test"
vim.lsp.config("test_missing", { cmd = { "absent-server" } })
vim.lsp.config("test_present", { cmd = { "present-server" } })
available["present-server"] = true
local opts = { servers = { test_missing = {}, test_present = {}, disabled = false, ["*"] = {} } }
tools.configure_servers(opts)
check(opts.servers.test_missing.enabled == false, "missing native LSP skipped")
check(opts.servers.test_present.enabled ~= false and opts.servers.test_present.mason == false, "native LSP retained")
check(opts.servers["*"].mason == nil and opts.servers.disabled == false, "wildcards and explicit disable preserved")
vim.env.TERMUX_VERSION = nil
opts = { servers = { test_missing = {} } }
tools.configure_servers(opts)
check(
  opts.servers.test_missing.enabled == nil and opts.servers.test_missing.mason == nil,
  "desktop Mason installation retained"
)

local formatter_available = { jq = true }
package.loaded.conform = {
  get_formatter_info = function(name)
    return { available = formatter_available[name] == true }
  end,
}
opts = dofile("lua/plugins/formatting.lua")[1].opts
tools.guard_formatters(opts)
check(vim.deep_equal(opts.formatters_by_ft.json(0), { "jq", stop_after_first = true }), "JSON jq fallback")
check(vim.deep_equal(opts.formatters_by_ft.jsonc(0), { stop_after_first = true }), "JSONC excludes jq")
formatter_available.prettier = true
check(opts.formatters_by_ft.jsonc(0)[1] == "prettier", "JSONC prettier fallback")
formatter_available.prettierd = true
check(opts.formatters_by_ft.json(0)[1] == "prettierd", "formatter precedence")

local project_config = false
package.loaded.lint = { linters = { example = { cmd = "linter" } } }
opts = {
  linters_by_ft = { lua = { "example" } },
  linters = { example = {
    condition = function()
      return project_config
    end,
  } },
}
tools.guard_linters(opts)
check(not opts.linters.example.condition({}), "linter project condition preserved")
project_config = true
check(not opts.linters.example.condition({}), "missing linter skipped")
available.linter = true
check(opts.linters.example.condition({}), "available linter with project config")

-- Importing specs on a fresh install must not require Catppuccin.
package.preload["catppuccin.palettes"] = function()
  error("eager palette import")
end
check(type(dofile("lua/plugins/catppuccin.lua")) == "table", "theme discovery before installation")
local dashboard = dofile("lua/plugins/dashboard.lua")[1].opts.dashboard.formats.file
local parts = dashboard({ file = [[C:\Users\Test User\project\main.lua]] }, { width = 120 })
check(parts[#parts][1] == "main.lua", "Windows dashboard filename")

vim.env.TERMUX_VERSION = "test"
local specs = {}
for _, spec in ipairs(dofile("lua/config/portability.lua")) do
  specs[spec[1]] = spec
end
check(specs["mason-org/mason.nvim"].enabled == false, "Termux disables Mason dependency")
check(specs["mason-org/mason-lspconfig.nvim"].enabled == false, "Termux disables Mason LSP dependency")
opts = { ensure_installed = { "lua", "python" } }
specs["nvim-treesitter/nvim-treesitter"].opts(nil, opts)
check(#opts.ensure_installed == 0, "missing parser prerequisites override extra install lists")
check(specs["mfussenegger/nvim-jdtls"].cond() == false, "Java skipped without native launcher")
check(specs["mrcjkb/rustaceanvim"].cond() == false, "Rust skipped without analyzer")
check(specs["L3MON4D3/LuaSnip"].build == false, "optional snippet build skipped without make")
opts = { adapters = { ["rustaceanvim.neotest"] = {}, ["neotest-python"] = {} } }
specs["nvim-neotest/neotest"].opts(nil, opts)
check(
  opts.adapters["rustaceanvim.neotest"] == nil and opts.adapters["neotest-python"] ~= nil,
  "missing Rust adapter does not remove Python tests"
)
vim.env.TERMUX_VERSION = nil
windows = true
local stat = vim.uv.fs_stat
local library_path
available.codelldb = true
vim.uv.fs_stat = function(path)
  library_path = path
  return { type = "file" }
end
local adapter, library = tools.codelldb()
check(adapter ~= nil and library:match("/bin/liblldb%.dll$") ~= nil, "Windows CodeLLDB DLL layout")
vim.uv.fs_stat = function()
  return nil
end
check(tools.codelldb() == nil, "incomplete CodeLLDB installation skipped")
windows = false
vim.uv.fs_stat = function(path)
  library_path = path
  return { type = "file" }
end
adapter, library = tools.codelldb()
check(adapter ~= nil and library:match("/lib/liblldb%.so$") ~= nil, "Linux CodeLLDB library layout")
vim.uv.fs_stat = stat
print("PASS: " .. count .. " portability assertions")
