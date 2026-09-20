-- Run after normal startup in the disposable config created by scripts/check.py.
vim.schedule(function()
  local ok, err = xpcall(function()
    -- Headless Neovim has no UIEnter; exercise the normal interactive lazy-load path.
    vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
    assert(
      vim.wait(5000, function()
        return vim.g.did_very_lazy == true
      end),
      "VeryLazy did not run"
    )
    local lazy = require("lazy")
    local config = require("lazy.core.config")
    local platform = require("util.platform")
    local notifications, errors, features = {}, {}, {}
    assert(config.plugins.catppuccin, "Catppuccin spec missing")
    assert(vim.g.colors_name and vim.g.colors_name:match("catppuccin"), "theme did not load")
    if platform.detect().termux then
      assert(not config.plugins["mason.nvim"], "extras re-enabled Mason on Termux")
      assert(not config.plugins["mason-lspconfig.nvim"], "extras re-enabled Mason LSP on Termux")
    end

    local samples = {
      { "sample.lua", "lua", "local value=1" },
      { "sample.py", "python", "value = 1" },
      { "sample.sh", "sh", "echo hello" },
      { "sample.json", "json", '{"value":1}' },
      { "sample.jsonc", "jsonc", '// keep this comment\n{"value": 1,}' },
      { "sample.md", "markdown", "# Sample" },
      { "Sample.java", "java", "class Sample {}" },
      { "sample.rs", "rust", "fn main() {}" },
    }
    for _, sample in ipairs(samples) do
      vim.cmd.edit(vim.fs.joinpath(vim.env.NVIM_TEST_WORK, sample[1]))
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(sample[3], "\n", { plain = true }))
      vim.bo.filetype = sample[2]
      vim.cmd.write()
      vim.wait(250)
      if sample[2] == "lua" then
        if platform.has("stylua") then
          assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "local value = 1", "StyLua did not format on save")
          features.stylua_on_save = true
        end
        if platform.tool("lua-language-server") then
          assert(
            vim.wait(15000, function()
              for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "lua_ls" })) do
                if client.initialized then
                  return true
                end
              end
              return false
            end),
            "available Lua language server did not attach"
          )
          features.lua_lsp_attached = true
        end
        if LazyVim.treesitter.have("lua") then
          assert(vim.treesitter.get_parser(0, "lua"):parse()[1], "installed Lua parser did not parse")
          features.lua_parser = true
        end
      end
    end
    assert(config.plugins["nvim-lspconfig"]._.loaded, "LSP file events did not load")
    assert(vim.fn.exists(":LazyFormat") == 2, "automatic formatting was not initialized")
    lazy.load({ plugins = { "conform.nvim", "blink.cmp", "LuaSnip", "nvim-treesitter", "lualine.nvim" } })
    assert(require("conform").format, "Conform did not load")
    assert(require("blink.cmp").is_visible, "completion did not load")
    assert(require("luasnip").expandable, "snippets did not load")
    assert(require("nvim-treesitter").get_installed, "Tree-sitter did not load")

    local conform = require("conform")
    vim.cmd.edit(vim.fs.joinpath(vim.env.NVIM_TEST_WORK, "sample.jsonc"))
    for _, formatter in ipairs(conform.list_formatters(0)) do
      assert(formatter.name ~= "jq", "JSONC selected jq")
    end
    assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("keep this comment", 1, true))
    features.jsonc_comments_preserved = true

    local output = vim.fn.system({
      vim.o.shell,
      platform.detect().windows and (vim.o.shell:find("powershell") or vim.o.shell:find("pwsh")) and "-Command"
        or platform.detect().windows and "/c"
        or "-c",
      "echo portable-shell",
    })
    assert(vim.v.shell_error == 0 and output:find("portable%-shell"), "shell invocation failed: " .. output)
    vim.cmd("checkhealth config")
    vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), vim.env.NVIM_TEST_WORK .. "/health.txt")
    -- Read Noice's captured messages without replacing vim.notify (which Noice monitors).
    for _, message in ipairs(require("noice.message.manager").get(nil, { history = true, sort = true })) do
      notifications[#notifications + 1] = message:content()
      if message.level == "error" then
        errors[#errors + 1] = message:content()
      end
    end
    vim.fn.writefile(notifications, vim.env.NVIM_TEST_WORK .. "/notifications.txt")
    vim.fn.writefile({ vim.json.encode(features) }, vim.env.NVIM_TEST_WORK .. "/features.json")
    assert(#errors == 0, table.concat(errors, "\n"))
    -- vim.v.errmsg also retains errors intentionally caught by plugins (e.g. deleting
    -- absent mappings). The runner checks emitted errors, not that stale register.
    io.stdout:write("PASS: startup, merged policy, filetypes, save, completion, snippets, theme, shell, and health\n")
  end, debug.traceback)
  vim.fn.writefile({ vim.fn.execute("messages") }, vim.env.NVIM_TEST_WORK .. "/messages.txt")
  if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
  else
    vim.cmd("qa!")
  end
end)
