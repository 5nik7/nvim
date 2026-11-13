local M = {}
local configured = false

-- nvim-treesitter has no per-process environment option. Keep these overrides
-- on its build/generate children instead of changing terminals or other tools.
function M.setup()
  if configured then
    return
  end
  configured = true
  local system = vim.system
  local platform = require("util.platform")
  local termux = platform.detect().termux

  ---@param cmd string[]
  ---@param opts? vim.SystemOpts
  ---@param on_exit? fun(out: vim.SystemCompleted)
  ---@return vim.SystemObj
  local function parser_system(cmd, opts, on_exit)
    local executable = cmd[1]:match("([^/\\]+)$")
    if
      (executable == "tree-sitter" or executable == "tree-sitter.exe") and (cmd[2] == "build" or cmd[2] == "generate")
    then
      opts = vim.tbl_extend("force", {}, opts or {})
      opts.env = vim.tbl_extend("force", {}, opts.env or {}, {
        -- The plugin echoes stderr as text; Noice does not interpret ANSI SGR.
        NO_COLOR = "1",
        CLICOLOR = "0",
        CLICOLOR_FORCE = "0",
        FORCE_COLOR = "0",
      })
      if termux and cmd[2] == "build" and not vim.tbl_contains(cmd, "--wasm") and not vim.tbl_contains(cmd, "-w") then
        -- cc-rs injects an unversioned Android target. Ask the native compiler
        -- for its API level, retaining cc-rs's optimization/PIC flags. Probe only
        -- when building, with a timeout; custom CC shell expressions pass through.
        local compiler = opts.env.CC or (not opts.clear_env and vim.env.CC) or platform.compiler()
        if platform.has(compiler) then
          local ok, result = pcall(function()
            return system({ compiler, "-dumpmachine" }, {
              text = true,
              timeout = 1000,
              env = opts.env,
              clear_env = opts.clear_env,
            }):wait()
          end)
          local target = ok and result.code == 0 and (result.stdout or ""):match("^%s*([%w_.%-]+)%s*$")
          if target and (target:match("%-android%d+$") or target:match("%-androideabi%d+$")) then
            local flags = opts.env.CFLAGS or (not opts.clear_env and vim.env.CFLAGS) or ""
            -- Put user flags last so an explicit target still takes precedence.
            opts.env.CFLAGS = "--target=" .. target .. (flags ~= "" and " " .. flags or "")
          end
        end
      end
    end
    return system(cmd, opts, on_exit)
  end
  rawset(vim, "system", parser_system)
end

return M
