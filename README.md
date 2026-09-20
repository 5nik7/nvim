# Neovim across Windows, WSL, Linux, and Termux

A personal LazyVim configuration with the same theme, keymaps, and language extras
on each platform. This is a **per-user** configuration: it becomes the default when
installed at Neovim's configuration directory. It does not install system packages.

## Requirements and behavior

Use Neovim **0.11.2 or newer**, built with LuaJIT, and Git **2.19 or newer**.
The latest stable Neovim is recommended. See the upstream
[LazyVim requirements](https://www.lazyvim.org/) and
[Mason prerequisites](https://github.com/mason-org/mason.nvim#requirements).
First installation and plugin updates require network access to GitHub and package
registries. Once installed, ordinary editing does not require a fresh bootstrap.

- Windows, Linux, and WSL use LazyVim's Mason integration for supported editor tools.
  Language runtimes and build tools still need to be installed separately.
- Termux uses native executables on PATH. Mason and mason-lspconfig are disabled,
  including dependencies introduced by language extras. Desktop Linux binaries
  are not interchangeable with Android binaries.
- Missing native servers, formatters, and linters are skipped. Editing and internal
  registers remain available. Install the missing tool and **restart Neovim** to
  re-evaluate server/plugin availability.
- Parser auto-installation requires a C compiler, `tree-sitter`, `curl`, and `tar`.
  Existing parsers remain usable without those tools. After installing prerequisites,
  restart and run `:TSUpdate`. CLI/compiler versions must also meet the requirements
  of the resolved nvim-treesitter revision (`:checkhealth nvim-treesitter`).
- Completion uses Blink's native matcher when available and falls back to Lua.
  LuaSnip's optional regex extension builds only with a compiler and Make on Unix.
- LuaRocks support uses an existing system `luarocks`; it does not bootstrap
  Hererocks. Git dependencies provide the enabled plugins' ordinary functionality.
- The disabled Obsidian integration stays disabled. The configured palette and
  dashboard do not require pywal output to exist.

## Install as the default config

Check the destination using an existing Neovim session:

```vim
:echo stdpath('config')
:echo stdpath('data')
```

| Platform | Conventional config directory | Clipboard setup |
| --- | --- | --- |
| Linux | `~/.config/nvim` | `wl-copy`/`wl-paste` for Wayland, or `xclip`/`xsel` for X11 |
| WSL | `~/.config/nvim` inside the distribution | Prefer `win32yank.exe` on WSL's PATH; otherwise Neovim detects a provider |
| Termux | `~/.config/nvim` in Termux's private home | Termux:API app plus the `termux-api` package |
| Native Windows | `%LOCALAPPDATA%\nvim` | Neovim's detected Windows clipboard provider; optional `win32yank.exe` |

These paths assume default `NVIM_APPNAME` and XDG settings. Honor the actual
`stdpath('config')` result if you override them. Keep separate plugin/data/cache
installations for Windows, WSL, Linux, and Android; share configuration source only.
Use a Nerd Font in your terminal for the configured icons.

### Linux, WSL, or Termux

Close Neovim first. These commands preserve an existing directory **or symlink**
under a unique backup name, then clone this repository. They assume the default
application name `nvim`.

```sh
nvim_config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim_backup="${nvim_config}.backup-$(date +%Y%m%d-%H%M%S)"
if [ -e "$nvim_backup" ] || [ -L "$nvim_backup" ]; then
  printf '%s\n' "Backup already exists: $nvim_backup"
elif [ -e "$nvim_config" ] || [ -L "$nvim_config" ]; then
  mv -- "$nvim_config" "$nvim_backup"
fi
# Run only once the config destination is absent.
git clone https://github.com/5nik7/nvim.git "$nvim_config"
```

To use an existing checkout instead of cloning, create the config parent directory
and link the checkout at the absent destination:

```sh
mkdir -p -- "$(dirname "$nvim_config")"
ln -s -- /absolute/path/to/checkout "$nvim_config"
```

The current development machine's active config was linked through a separate
`dots/androidots` checkout. Moving that link preserves its target; this repository's
implementation does not replace it automatically.

### Native Windows (PowerShell)

Close Neovim. For the default config location:

```powershell
$nvimConfig = Join-Path $env:LOCALAPPDATA 'nvim'
$nvimBackup = "$nvimConfig.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
if (Get-Item -LiteralPath $nvimBackup -Force -ErrorAction SilentlyContinue) {
  throw "Backup already exists: $nvimBackup"
}
if (Get-Item -LiteralPath $nvimConfig -Force -ErrorAction SilentlyContinue) {
  Move-Item -LiteralPath $nvimConfig -Destination $nvimBackup -ErrorAction Stop
}
git clone https://github.com/5nik7/nvim.git $nvimConfig
```

Alternatively, at an absent destination, create a junction to an existing local
checkout (use its absolute path):

```powershell
New-Item -ItemType Junction -Path $nvimConfig -Target 'C:\path\to\checkout'
```

The configuration selects `pwsh` when available, then Windows PowerShell, and
otherwise keeps Neovim's default shell. WSL keeps its Linux shell.

### First launch and rollback

Run `nvim`, allow plugin installation to finish, and restart. On desktop platforms,
open a source file to load language tooling, allow Mason installs to finish, then
restart again. Check `:Lazy`, `:checkhealth config`, and `:messages`.

For rollback, close Neovim, **rename the new config directory or link** to a separate
name, and restore the saved backup to the original location. Do not delete a linked
checkout or junction target. Plugin data is separate: preserve it before changing
or rolling back plugin versions as well. `:echo stdpath('data')` identifies it.

## External tools

Install core tools with the platform's package manager; this repo never invokes
`sudo`, `winget`, `apt`, or `pkg`. Package names and supported architectures vary.

| Platform | Practical prerequisites |
| --- | --- |
| Linux / WSL | Recent Neovim, Git, curl, tar, unzip, ripgrep, fd; GCC or Clang and tree-sitter CLI for parsers. Node/npm and Python/venv for the relevant Mason packages. Some distributions name the fd executable `fdfind`; expose it as `fd` on PATH. |
| Windows | Recent Neovim, Git, PowerShell, archive tools required by Mason, ripgrep, fd. Put a supported C compiler and tree-sitter CLI on PATH for parsers. Launch from a compiler-enabled shell if using MSVC. Install Node/npm and Python for the relevant language packages. |
| Termux | `pkg install neovim git curl tar unzip ripgrep fd clang make tree-sitter` provides the editing/parser foundation. Install `nodejs`, `python`, and language tools only as needed. Use native packages/builds rather than desktop release archives. |

For Android clipboard integration, install the Termux:API companion app from a
source compatible with your Termux app and install `termux-api` inside Termux.
Both `termux-clipboard-set` and `termux-clipboard-get` must be on PATH. Command
presence cannot prove Android permissions or the companion service are working.
On WSL, Windows interoperability must work for `win32yank.exe` to run.
An explicit `vim.g.clipboard` setting is preserved. Without a usable provider,
Neovim's own provider detection and normal internal registers remain available.

The enabled language extras remain shared across machines. Install only the tools
you use. On desktops, `:Mason` manages packages supported by its registry; on Termux,
check `pkg search`, the tool's official native-build instructions, or its runtime's
package manager. Availability in Mason does not guarantee availability on Android.

| Area | Server / runtime | Formatting, linting, or optional tools |
| --- | --- | --- |
| Lua | `lua-language-server` | `stylua`; `luacheck` runs only with a discoverable `.luacheckrc` and the existing project-root condition |
| Shell / Fish | `bash-language-server` with Node; `fish` | `shfmt`, `fish_indent` |
| Python | `basedpyright-langserver`, `ruff`, Python | Ruff formatting/import actions; project test dependencies for neotest |
| Go | `gopls`, Go | `goimports`, `gofumpt`, `golangci-lint`; project tests |
| Rust | `rust-analyzer`, Cargo / Rust | Cargo test/clippy; optional `codelldb` |
| Java | `jdtls`, a compatible JDK, launcher prerequisites | Optional Mason Java debug/test bundles on desktops |
| Kotlin | `kotlin-language-server`, compatible JDK | `ktlint`; optional `kotlin-debug-adapter` |
| TypeScript / JavaScript | `vtsls`, Node/npm, project TypeScript | Prettier; `biome` for projects configured to use it |
| JSON / JSONC | `vscode-json-language-server`, Node | First available `prettierd`, then `prettier`; JSON alone can fall back to `jq` |
| Markdown | `marksman` | Prettier, `markdownlint-cli2`, `markdown-toc`; Node/npm for browser preview |
| YAML | `yaml-language-server`, Node | Prettier |
| TOML | `taplo` | Server formatting |
| Tailwind | `tailwindcss-language-server`, Node | Project Tailwind dependencies |
| Zig | `zls`, compatible Zig | Zig formatting/testing |
| Nushell | `nu` (also supplies the language server) | Nushell runtime |
| Git / navigation | Git, `rg`, `fd` | Optional `lazygit` |

Browser Markdown preview installs JavaScript dependencies through npm instead of a
platform-specific bundled executable. If you add Node/npm later, restart and run
`:Lazy build markdown-preview.nvim`. A working browser/open command is still needed;
on Termux configure the plugin's browser option for `termux-open-url` if necessary.
Rust debugging uses Mason's CodeLLDB installation only when its executable and
platform-specific liblldb library both exist. A custom native adapter can be supplied
through `vim.g.rustaceanvim`; absent adapters do not block Rust editing.

## Diagnostics and updates

`:checkhealth config` reports platform, paths, shell, clipboard provider selection,
parser prerequisites, and tool availability without installing tools or reading or
writing clipboard contents. Warnings describe optional capabilities, not a requirement
to install every listed tool. Use `:ConformInfo`, `:checkhealth vim.lsp`,
`:checkhealth nvim-treesitter`, and `:messages` for deeper inspection.

Update this checkout with Git, then use `:Lazy update`. Retain a copy of your local
`lazy-lock.json` before updates; restore it and run `:Lazy restore` to restore those
plugin revisions. The lockfile is intentionally ignored, so different machines can
resolve different revisions. CI retains its resolved lockfile with the logs.
Neovim, language runtimes, Mason tools, and native Termux packages have separate
update lifecycles. Re-run checks after updates.

## Validation

From this repository:

```sh
stylua --check init.lua lua/ tests/
nvim --headless -u NONE -i NONE -l tests/portability.lua
python scripts/check.py
```

The Python runner copies this config into temporary directories, isolates all four
XDG locations, and uses a sample project whose path contains spaces. It checks fresh
bootstrap, subsequent startup, lazy-loaded features, representative filetypes and
saving, shell invocation, and health reporting. It emits a synthetic `UIEnter` event
because headless Neovim does not attach a terminal UI. Logs and resolved plugin
versions are retained under ignored `.tests/results/`; temporary installations are
removed afterward. A plain `nvim --headless '+qa'` alone misses these lazy-load paths.

For a restricted-network **seeded** check, copy already installed plugins/parsers:

```sh
python scripts/check.py \
  --seed-plugins "$HOME/.local/share/nvim/lazy" \
  --seed-parsers "$HOME/.local/share/nvim/site" \
  --skip-parser-downloads \
  --output .tests/seeded
```

Use the actual data paths on your machine. This mode injects unavailable parser-build
capability and tests copied native parsers; it does **not** establish fresh-download
or parser-build success. Never copy native parsers from another OS or architecture.

GitHub Actions defines Linux and native Windows jobs for Neovim 0.11.2 and latest
stable, plus formatting checks. WSL and Android require separate native checks.
A workflow definition is not evidence that its jobs have already passed.

For each native platform, record OS/architecture, Neovim version, plugin lockfile,
and the following results:

1. Run the isolated checks above, then inspect `:checkhealth config` and `:messages`.
2. Open a real project for each language you use; verify LSP attachment, diagnostics,
   completion, formatting on save, and test/debug integrations you have installed.
3. Copy and paste multiline text between Neovim and another app. On WSL, include
   Windows interoperability; on Android, include Termux:API permissions.
4. Open the dashboard, picker/explorer, a terminal, and a snippet. Check icons,
   highlighting, keymaps, and paths containing spaces. On Windows also use backslashes.
5. Test with optional tooling absent: opening/saving must still work, health should
   explain what is missing, and JSONC comments must survive formatting.

Actual validation results for this change are recorded in [docs/validation.md](docs/validation.md).
