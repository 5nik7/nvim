-- vim.g.loaded_python3_provider = 0
-- vim.g.loaded_perl_provider = 0
-- vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
--

if vim.fn.has("win32") == 1 then
  LazyVim.terminal.setup("pwsh")
end