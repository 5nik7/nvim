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
  if name == "catppuccin" then
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
