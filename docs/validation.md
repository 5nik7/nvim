# Portability validation

Implementation validation used native **Termux on Android ARM64**, Neovim **0.12.5**
with LuaJIT. The active config location was not changed. These checks were performed
before publication.

| Check | Result |
| --- | --- |
| `stylua --check init.lua lua/ tests/` | Passed |
| `git diff --check` | Passed |
| Python runner syntax and JSON/YAML parsing | Passed; workflow jobs were not executed |
| Dependency-free portability tests | 41 assertions passed; Windows/WSL and missing-tool cases use simulated capabilities |
| Missing Git bootstrap | Expected exit code 1 with actionable diagnostic; no keypress wait |
| Isolated native Termux integration | Passed with copied plugin and native parser caches |
| Actual StyLua formatting on save | Passed |
| Native Lua language server initialization and attachment | Passed |
| Existing native Lua parser loading and parsing | Passed |
| JSONC formatting | Comment preserved; jq excluded |
| Completion, snippets, theme, shell, and custom health check | Passed headlessly |
| Fresh GitHub bootstrap | Blocked by HTTP 403 from the network proxy; graceful error exit confirmed |
| Fresh parser downloads/builds | Downloads returned HTTP 403; compilation not established |
| Native Linux, Windows, and WSL | Not executed in this environment |
| Interactive UI and clipboard round trips | Not executed |

The integration test opens and saves Lua, Python, shell, JSON, JSONC, Markdown,
Java, and Rust buffers. This establishes buffer/editing behavior; it does not prove
that every language server, debugger, or test runner works. The Lua server was
specifically checked for successful attachment. Missing native servers remained
skipped, and merged specs excluded Mason and mason-lspconfig on Termux.

Headless testing emits a synthetic `UIEnter` event to exercise `VeryLazy` plugins.
It checks Noice's captured error messages as well as process output. This is not a
visual UI test. The final run injected unavailable parser-build capability to avoid
blocked downloads; existing native parser binaries were copied and actually loaded.

## Pi plugin integration

On native Termux with Neovim 0.12.5, `stylua --check lua/plugins/pi.lua` and
`git diff --check` passed. A disposable clone of `pablopunk/pi.nvim` at
`fab2a7932a5478e522d609a9fd39a7aac6c0440d` loaded successfully under
`nvim --headless -u NONE -i NONE` with isolated HOME and XDG roots.
The focused check verified setup, all four upstream commands, selection-range
forwarding, unique mappings, and no overlap with the configured Codex shortcuts.
Command handlers were stubbed: no AI requests, credentials, or live config startup
were involved. This does not establish interactive prompting, authenticated RPC,
full LazyVim loading, or native Windows/WSL/Linux operation.

## Reproduce the successful run

```sh
python scripts/check.py \
  --seed-plugins "$HOME/.local/share/nvim/lazy" \
  --seed-parsers "$HOME/.local/share/nvim/site" \
  --skip-parser-downloads \
  --output .tests/termux-final
```

Use your real plugin/data paths. The runner copies them into disposable directories
and does not build or install into the source caches. Results are retained locally
in ignored `.tests/termux-final/`, including `environment.json`, `features.json`,
`health.txt`, `notifications.txt`, command logs, and the full `lazy-lock.json`.
The failed fresh bootstrap is recorded in `.tests/termux-fresh/install.log`.
These local artifacts are not committed.

Selected plugin revisions from the successful run:

| Plugin | Commit |
| --- | --- |
| `LazyVim` | `999700997f72227187d49d8b92667183dc7fc809` |
| `lazy.nvim` | `85c7ff3711b730b4030d03144f6db6375044ae82` |
| `nvim-lspconfig` | `ffd261c09c3dabd0bf1a438f47a8ae3b22f3c3ff` |
| `nvim-treesitter` | `9a168f6357ed21c3a636e1727bc7d382abc451b8` |
| `conform.nvim` | `016802de402556da54c36bd7359b441266b01cdd` |
| `blink.cmp` | `78336bc89ee5365633bcf754d93df01678b5c08f` |

## Outstanding native evidence

The added GitHub Actions workflow defines Linux and Windows jobs for Neovim 0.11.2
and latest stable, using a fresh configuration and retaining logs and plugin
revisions. Its results remain pending until the workflow runs. The 0.11.2 minimum
is the configured target, not a locally executed result.

Run the README's native checklist on WSL and the other target platforms, including
clipboard interoperability, terminal behavior, visible UI, and the language
integrations you actually use. Re-run a fresh bootstrap and parser installation on
a network that permits the required downloads. Markdown preview's npm build and
native debugger execution also remain unverified by the seeded run.

## Anodize integration (2026-09-25)

Native Termux isolated validation through the Dots parent: five focused editor
integration cases, 23 shared-theme tests and 11 workflow tests passed without
skips. The editor consumes actual fixture publications for all 17 native
family/flavor combinations, a generic theme and an Anodize-authored theme.
No native family plugin is loaded by the bridge.

Checks cover explicit early loading with a copied real Lazy loader, active-only
reload and manual selection, last-good colors, raw legacy helpers, fallback,
Mocha exceptions, transparent main windows, opaque floats, terminal-color opt-out,
15% inactive foreground dimming, lualine layout/update behavior, dashboard repaint
without phase reset, visibility pause/resume, opt-out and cleanup. The animation
source is byte-identical to the pre-integration version. Tests use disposable
HOME/XDG/runtime and copied public sources; the normal LazyVim configuration was
not launched and nothing was installed or activated in a live editor.

Visual verification of third-party UI surfaces and a normal interactive startup
remain owner checks. Anodize renders syntax consistently across families; it does
not promise exact native-plugin syntax highlighting.

The parent's five-sample minimal-editor benchmark measured median 65.59 ms for Anodize standalone and 75.65 ms with the shared Dots startup bridge. These include process startup and configured highlights, not the full LazyVim plugin set; ordinary device-load variation applies.

## Tree-sitter parser builds (2026-11-12)

Implemented a scoped subprocess environment in `lua/util/treesitter.lua`, enabled
from both the Tree-sitter options and Lazy build hooks. Native Termux reproduction
used Neovim 0.12.6, tree-sitter 0.27.2, Clang 21.1.8, nvim-treesitter `60c0f468`
and Tera grammar `5fff1363a3e474765ee8dfd546630c2a8a7c6cc4`.

The original build failed in Android's `sys/cdefs.h` with `Unversioned target
triples are not supported!`. Tree-sitter's
[compiler configuration](https://github.com/tree-sitter/tree-sitter/blob/v0.27.2/crates/loader/src/loader.rs)
uses its Rust build target, which omits the Android API level. On Termux, the helper
asks the selected compiler for its native target with `-dumpmachine` and supplies
that target through the build child's `CFLAGS`. It preserves compiler optimization
and PIC defaults, appends existing user flags last, and leaves WebAssembly builds
alone. Custom `CC` shell expressions and unrecognized/failed compiler probes pass
through unchanged. The probe is bounded to one second and runs only during builds;
ten native probes measured 83.27 ms median and 132.19 ms maximum, with no startup
probe or persistent cache.

Build/generate children receive plain-output environment settings before
nvim-treesitter forwards their diagnostics to `:messages`, Noice and `:TSLog`.
Other subprocesses and the editor's environment retain their settings.

Verification used temporary HOME/XDG/config/data/state/cache roots, copied plugin
and grammar sources, and a path containing spaces and Unicode:

- The unmodified Tera grammar compiled, installed, loaded, and parsed `Hello {{ name }}!` without errors.
- The actual Lazy build hook rebuilt an outdated Tera revision; a repeat update reported it current.
- An injected C compiler error remained visible, with its full detail and no ANSI escapes in `:messages` or `:TSLog`, even with forced color in the parent environment.
- `tests/treesitter.lua` passed 91 subprocess assertions; the existing portability suite passed 41 assertions. The new test is included in `scripts/check.py`.
- Focused LuaLS checks for the helper, platform helper and new test reported no problems.
- All Lua formatting checks, Python runner syntax, affected Markdown links and whitespace checks passed. The existing Codex terminal suite passed 85 assertions, including real PTY replies. The parent Wiki build was unchanged and its check was healthy.

Native Linux, WSL, Windows, a full Lazy plugin update, and interactive Noice
rendering were not exercised. Platform simulations verify that the Android target
adjustment is Termux-only; they do not establish native desktop compiler behavior.
The real editor, plugin installation and parser caches were not modified.
