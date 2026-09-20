local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  if vim.fn.executable("git") ~= 1 then
    vim.api.nvim_err_writeln(
      "Cannot install lazy.nvim: install Git and make it available on PATH, then restart Neovim."
    )
    vim.cmd("cquit 1")
  end
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nCheck Git, network access, and permissions for " .. lazypath .. ", then restart Neovim." },
    }, true, {})
    vim.cmd("cquit 1")
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
    -- Apply capability policy after LazyVim extras and local specifications.
    { import = "config.portability" },
  },
  defaults = {
    lazy = true,
    version = false, -- always use the latest git commit
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  rocks = { enabled = vim.fn.executable("luarocks") == 1, hererocks = false },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
