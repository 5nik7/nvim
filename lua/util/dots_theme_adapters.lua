-- Native plugin adapters. Each setup starts from the user's original plugin options.
local M = {}
local bases = {}
local function base(name, config)
  if not bases[name] then
    bases[name] = vim.deepcopy(config)
  end
  return vim.deepcopy(bases[name])
end

function M.prepare(data)
  local name, flavor, palette = data.theme, data.flavor, data.palette
  if data.adapter == "generic" then
    local r, p = data.roles, data.palette
    return function()
      vim.cmd("highlight clear")
      vim.g.colors_name = "dots-" .. (data.id or name)
      local groups = {
        Normal = { fg = r.foreground, bg = "NONE" },
        NormalFloat = { fg = r.foreground, bg = r.background },
        FloatBorder = { fg = r.muted },
        Comment = { fg = r.muted, italic = true },
        String = { fg = p.green or r.hint },
        Character = { link = "String" },
        Number = { fg = p.orange or r.warning },
        Boolean = { link = "Number" },
        Constant = { fg = r.warning },
        Identifier = { fg = r.foreground },
        Function = { fg = p.blue or r.info },
        Statement = { fg = p.magenta or r.accent },
        Keyword = { link = "Statement" },
        Type = { fg = r.warning },
        PreProc = { fg = r.accent },
        Special = { fg = r.hint },
        Error = { fg = r.error },
        Visual = { bg = r.selection },
        CursorLine = { bg = r.selection },
        LineNr = { fg = r.muted },
        CursorLineNr = { fg = r.accent },
        Search = { fg = r.background, bg = r.warning },
        Pmenu = { fg = r.foreground, bg = r.background },
        PmenuSel = { fg = r.foreground, bg = r.selection },
        StatusLine = { fg = r.foreground, bg = r.selection },
        DiagnosticError = { fg = r.error },
        DiagnosticWarn = { fg = r.warning },
        DiagnosticInfo = { fg = r.info },
        DiagnosticHint = { fg = r.hint },
        ["@variable"] = { fg = r.foreground },
        ["@function"] = { link = "Function" },
        ["@keyword"] = { link = "Keyword" },
        ["@string"] = { link = "String" },
        ["@comment"] = { link = "Comment" },
        SnacksDashboardHeader = { fg = r.accent },
        SnacksDashboardIcon = { fg = r.accent },
      }
      for group, value in pairs(groups) do
        vim.api.nvim_set_hl(0, group, value)
      end
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = vim.g.colors_name })
    end
  elseif name == "catppuccin" then
    local plugin = require("catppuccin")
    local opts = base(name, plugin.options)
    opts.flavour = flavor
    opts.color_overrides = vim.tbl_deep_extend("force", opts.color_overrides or {}, { [flavor] = palette })
    -- The Lazy options callback already supplies this snapshot on startup. A
    -- second setup would change Catppuccin's input hash and rebuild its cache.
    local configured = plugin.options.flavour == flavor
      and vim.deep_equal((plugin.options.color_overrides or {})[flavor], palette)
    return function()
      if not configured then
        plugin.setup(opts)
      end
      vim.cmd.colorscheme("catppuccin-" .. flavor)
    end
  elseif name == "tokyonight" then
    local plugin = require("tokyonight")
    local opts = base(name, require("tokyonight.config").options)
    opts.style = flavor
    opts.cache = false -- cached plugin output must never hide palette-file edits
    local original = opts.on_colors
    opts.on_colors = function(colors)
      if original then
        original(colors)
      end
      for key, value in pairs(palette) do
        colors[key] = value
      end
    end
    return function()
      plugin.setup(opts)
      vim.cmd.colorscheme("tokyonight-" .. flavor)
    end
  elseif name == "rose-pine" then
    local plugin = require("rose-pine")
    local opts = base(name, require("rose-pine.config").options)
    opts.variant = flavor
    opts.palette = vim.tbl_deep_extend("force", opts.palette or {}, { [flavor] = palette })
    return function()
      plugin.setup(opts)
      vim.cmd.colorscheme("rose-pine-" .. flavor)
    end
  elseif name == "kanagawa" then
    local plugin = require("kanagawa")
    local opts = base(name, plugin.config)
    opts.theme = flavor
    opts.compile = false
    opts.colors = vim.tbl_deep_extend("force", opts.colors or {}, { palette = palette })
    return function()
      plugin.setup(opts)
      vim.cmd.colorscheme("kanagawa-" .. flavor)
    end
  elseif name == "gruvbox" then
    local plugin = require("gruvbox")
    local opts = base(name, plugin.config)
    opts.palette_overrides = vim.tbl_extend("force", opts.palette_overrides or {}, palette)
    return function()
      plugin.setup(opts)
      vim.cmd.colorscheme("gruvbox")
    end
  elseif name == "pywal16" then
    -- Use the upstream highlight renderer with validated snapshot colors. Its
    -- normal setup sources a live Vimscript export, which snapshots must avoid.
    require("pywal16.highlights")
    return function()
      vim.cmd.colorscheme("dots-pywal16")
    end
  end
  error("unsupported dots theme")
end

return M
