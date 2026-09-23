# Repository Guidelines

## Project Structure & Module Organization

This repository contains a personal Neovim configuration based on LazyVim.
`init.lua` loads `lua/config/lazy.lua`, which bootstraps lazy.nvim and imports
LazyVim plus local plugin specifications.

- `lua/config/`: startup options, keymaps, autocommands, and plugin-manager setup.
- `lua/plugins/`: plugin specifications and overrides, grouped by plugin or concern
  (for example, `lsp.lua` and `formatting.lua`).
- `lua/util/`: shared helpers and UI banner assets.
- `snippets/lua.json`: Lua snippets.
- `lazyvim.json`: enabled LazyVim extras and installation metadata.

## Build, Test, and Development Commands

There is no build step. With this checkout configured as Neovim's configuration
directory and dependencies installed:

- `nvim`: launch the configuration for interactive development. First startup can
  clone lazy.nvim and install plugins; Git and network access are needed.
- `nvim --headless "+qa"`: smoke-check startup; inspect output for errors.
- `stylua --check init.lua lua/`: check Lua formatting without modifying files.
- `stylua init.lua lua/`: format Lua using `stylua.toml`.
- `:checkhealth`: inspect runtime and external-tool problems inside Neovim.
- `:Lazy`: inspect plugin installation and loading status.

## Coding Style & Naming Conventions

Use two-space indentation, UTF-8, LF endings, and a final newline as specified in
`.editorconfig`. StyLua sets a 120-column target. Follow existing Lua conventions:
local variables, double-quoted strings, and snake_case helper names. Keep plugin
specifications in descriptive lowercase files under `lua/plugins/`; return spec
tables and place reusable helpers in `lua/util/`. Target Neovim's LuaJIT runtime.
Lua linting is configured through nvim-lint, but Luacheck requires a discoverable
`.luacheckrc`; none is tracked here.

## Testing Guidelines

No repository test suite, test naming convention, or coverage threshold is defined.
Run formatting and startup checks, then exercise changed functionality interactively.
For lazy-loaded plugins, open the relevant filetype or invoke the affected command.
Check `:messages` for errors and verify affected keymaps, formatting, or UI behavior.
Record the platform and checks performed.

## Commit & Pull Request Guidelines

Recent commits use timestamped subjects such as `Update @ ...` and
`Sync via termux on ...`; no strict commit format is established. Prefer concise,
descriptive subjects for focused changes. PRs should explain the behavior changed,
list validation, link relevant issues, and include screenshots for visible UI changes.

## Configuration Precautions

Preserve Termux, WSL, and Windows handling in `lua/config/options.lua`. Avoid adding
machine-specific paths or credentials. `lazy-lock.json` is ignored and untracked;
do not force-add it incidentally.

## Dots Integration

When nested at Dots `config/nvim`, maintain `.dots/files.json` as this repository's
resource catalog. The shared theme reader consumes validated JSON via the stable
XDG state `dots/current/theme` link, with legacy fallback. Keep generic imported
themes data-only; do not execute downloaded Lua. Use the parent's isolated
`tools/test_themes.py` and `tools/test_theme_workflow.py` for bridge changes rather
than launching live LazyVim or installing plugins as a test.
