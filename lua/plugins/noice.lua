local function popup_width()
  local columns = vim.o.columns
  -- Reserve two border columns and one padding column on each side.
  return columns >= 64 and 60 or math.max(1, math.min(columns - 4, math.floor(columns * 0.8)))
end

return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      local termux = require("util.platform").detect().termux
      opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
        view = termux and "cmdline" or "cmdline_popup",
      })
      opts.presets = vim.tbl_deep_extend("force", opts.presets or {}, {
        command_palette = not termux,
      })
      if not termux then
        opts.views = vim.tbl_deep_extend("force", opts.views or {}, {
          cmdline_popup = { size = { width = popup_width(), min_width = 1 } },
          cmdline_popupmenu = { size = { width = popup_width() } },
        })
      end

      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("config_noice_layout", { clear = true }),
        callback = vim.schedule_wrap(function()
          local config = require("noice.config")
          if not config.is_running() then
            return
          end
          local width = popup_width()
          if not termux then
            config.options.views.cmdline_popup.size.width = width
            config.options.views.cmdline_popupmenu.size.width = width
          end

          -- Noice caches each command format's view options. Update those too,
          -- so resizing works without calling setup again or losing messages.
          for _, cached in ipairs(require("noice.view")._views) do
            local view = cached.view
            local name = view._view_opts.view
            if not termux and name == "cmdline_popup" then
              view._view_opts.size.width = width
            end
            if name == (termux and "cmdline" or "cmdline_popup") and view._visible then
              view:display()
            end
          end

          local popupmenu = require("noice.ui.popupmenu")
          if popupmenu.state.visible and popupmenu.state.grid == -1 then
            popupmenu.backend.on_show(popupmenu.state)
          end
        end),
      })
    end,
  },
}
