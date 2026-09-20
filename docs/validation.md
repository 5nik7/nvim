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
