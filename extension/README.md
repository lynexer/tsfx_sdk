# TSFX VSCode Extension

VSCode extension for [TSFX Bridge SDK](https://github.com/lynexer/tsfx_sdk) development support in FiveM.

## Features

- **Workspace Detection** — Automatically detects FiveM resources that depend on `tsfx_sdk`.
- **LuaLS Type Injection** — Injects TSFX SDK type definitions into `Lua.workspace.library` for full IntelliSense.
- **Code Snippets** — Rich snippet library covering the entire TSFX API surface.
- **Diagnostics** — Custom lint rules for common TSFX SDK usage mistakes (wrong context calls, unknown money accounts).

## Requirements

- VSCode `^1.80.0`
- [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) (recommended)

## Extension Settings

| Setting | Default | Description |
|---|---|---|
| `tsfx.diagnostics.wrongContext` | `true` | Warn when TSFX SDK methods are called in the wrong context. |
| `tsfx.diagnostics.unknownMoneyAccount` | `true` | Warn when an unrecognised money account string is passed. |

## Known Issues

See [GitHub Issues](https://github.com/lynexer/tsfx_sdk/issues).
