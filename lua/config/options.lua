-- vim.g.loaded_python3_provider = 0
-- vim.g.loaded_perl_provider = 0
-- vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
--
local opt = vim.opt

opt.guicursor = {
  "a:block",
  "n:Cursor",
  "o-c:iCursor",
  "v:vCursor",
  "i-ci-sm:ver30-iCursor",
  "r-cr:hor20-rCursor",
  "a:blinkon0",
}

if vim.fn.has("win32") == 1 then
  LazyVim.terminal.setup("pwsh")
end