# TSFX Bridge SDK - Project Structure

This document defines the canonical structure for the TSFX Bridge SDK monorepo.

---

## Monorepo Root

This is a **pnpm monorepo** with a flat package layout.

```
tsfx_sdk/
├── resource/
├── scripts/
├── docs/
│   ├── structure.md
│   └── typing-conventions.md
├── package.json
├── pnpm-workspace.yaml
├── .gitignore
├── .editorconfig
├── README.md
└── CHANGELOG.md
```

---

## `resource/` — The FiveM Resource (`tsfx_sdk`)

```
resource/
├── fxmanifest.lua
├── init.lua                          ← TSFX global facade, loaded into consumer VM
├── .luarc.json
│
├── shared/
│   ├── utils/
│   │   ├── context.lua               ← isServer(), isClient(), getContext()
│   │   └── manifest.lua              ← ManifestBuilder
│   ├── adapters.lua                  ← AdapterRegistry configuration
│   ├── config.lua
│   ├── constants.lua
│   ├── enums.lua
│   └── types/                        ← LuaLS @meta only, never executed at runtime
│       ├── adapters/
│       ├── facades/
│       ├── config.lua
│       ├── context.lua
│       ├── eventbus.lua
│       ├── exports.lua
│       ├── log.lua
│       ├── manifest.lua
│       ├── statemachine.lua
│       └── tsfx.lua
│
├── core/                             ← Internal SDK utilities (flat files)
│   ├── services/                     ← Runtime services
│   │   ├── event_bus.lua             ← mode = 'export'
│   │   ├── event_bus_facade.lua      ← mode = 'consumer_vm'
│   │   ├── cache.lua                 ← mode = 'export'
│   │   ├── await.lua                 ← mode = 'export'
│   │   ├── tick.lua                  ← mode = 'export'
│   │   ├── log_instance.lua          ← mode = 'consumer_vm'
│   │   ├── exports.lua               ← mode = 'export'
│   │   └── facade_base.lua           ← mode = 'consumer_vm' (base class for handles)
│   └── utils/                        ← Builders & registries
│       ├── context.lua
│       ├── manifest.lua
│       ├── module_builder.lua        ← ModuleBuilder + MethodsBuilder
│       └── adapter_registry.lua
│
├── adapters/                         ← Framework-specific implementations
│   ├── framework/
│   │   ├── _base_client.lua          ← Client adapter interface
│   │   ├── _base_server.lua          ← Server adapter interface
│   │   ├── client/
│   │   │   ├── esx.lua
│   │   │   ├── qbcore.lua
│   │   │   └── qbox.lua
│   │   └── server/
│   │       ├── esx.lua
│   │       ├── qbcore.lua
│   │       └── qbox.lua
│   ├── inventory/
│   │   ├── _base.lua
│   │   ├── _custom.lua
│   │   ├── ox_inventory.lua
│   │   └── ps-inventory.lua
│   ├── notify/
│   │   ├── _base.lua
│   │   ├── esx.lua
│   │   ├── ox_lib.lua
│   │   └── qb.lua
│   └── ... (dispatch, fuel, interact, keys, medical, phone, progress)
│       └── each: _base.lua + _custom.lua + framework files
│
├── features/                         ← Public API surface
│   ├── player/
│   │   ├── facade.lua                ← PlayerHandle (consumer_vm, callable)
│   │   ├── job_facade.lua            ← JobHandle (consumer_vm, callable)
│   │   ├── gang_facade.lua           ← GangHandle (consumer_vm, callable)
│   │   ├── server.lua                ← Player module (export, hidden)
│   │   └── client.lua                ← Player module (export, hidden)
│   ├── framework/
│   │   ├── facade.lua                ← FrameworkHandle (consumer_vm, callable)
│   │   └── server.lua                ← Framework module (export, hidden)
│   ├── inventory/
│   │   ├── facade.lua                ← InventoryHandle (consumer_vm)
│   │   └── server.lua                ← Inventory module (export, hidden)
│   ├── notify/
│   │   ├── facade.lua                ← NotifyHandle (consumer_vm)
│   │   └── server.lua                ← Notify module (export, hidden)
│   ├── grid/
│   │   ├── facade.lua                ← GridHandle (consumer_vm)
│   │   └── shared.lua                ← Shared grid logic (export)
│   ├── zone/
│   │   ├── facade.lua                ← ZoneHandle (consumer_vm)
│   │   └── shared.lua                ← Shared zone logic (export)
│   ├── state/
│   │   ├── machine.lua               ← StateMachine (consumer_vm)
│   │   └── builder.lua               ← StateMachineBuilder (consumer_vm)
│   ├── entity/
│   │   ├── manager.lua               ← EntityManager (export)
│   │   └── streaming.lua             ← Streaming helper (export)
│   ├── interact/
│   │   ├── facade.lua                ← InteractHandle (consumer_vm)
│   │   └── client.lua                ← Interact module (export, hidden)
│   └── locale/
│       └── shared.lua                ← Locale module (export)
│
├── server/
│   └── main.lua                      ← Server bootstrap: load services, features, bind, finalize
│
└── client/
    └── main.lua                      ← Client bootstrap: load services, features, bind, finalize
```

---

## `scripts/` — Build Tooling

```
scripts/
├── package.json
├── tsconfig.json
├── .env.example                      ← SERVER_PATH=...
└── src/
    ├── dev.ts
    ├── dev-watch.ts
    ├── generate-test-resource.ts
    └── utils/
        ├── paths.ts
        └── server.ts
```

---

## Architectural Layers

| Layer | Folder | Consumed by |
| -- | -- | -- |
| Public API routing | `init.lua` | Consuming devs (`TSFX:Player()`) |
| Chainable handles | `features/*/facade.lua` | `init.lua` — instantiated per call |
| Feature logic | `features/*/*.lua` | `main.lua` (loaded into manifest) |
| Framework translation | `adapters/` | Feature modules via AdapterRegistry |
| SDK utilities | `core/` | Everything internally |
| Shared contracts | `shared/types/` | LuaLS only — never runtime |

---

## Key Conventions

* **`init.lua`** is the public API entry point — loaded by consuming resources via `@tsfx_sdk/init.lua`, not listed in fxmanifest
* **`server/main.lua`** and **`client/main.lua`** are the resource's own bootstrap, loaded by fxmanifest. They call `Manifest:load()`, `Manifest:bind()`, and `Manifest:finalize()`
* **Core files are flat** — no `_index.lua` folder pattern. They have a
  **dual responsibility**: define their global class (for runtime use) AND return a
  `ModuleDeclaration` built via `ModuleBuilder` (for the manifest builder)
* **Feature facades are consumer_vm** — loaded directly into the consumer's Lua VM so metatables survive
* **Feature modules are export** — registered as FiveM exports, called by facades via `exports.tsfx_sdk`
* Use the `ModuleBuilder` API to declare modules — never hand-write the
  `ModuleDeclaration` table. The global alias `Module` is available in module
  files and resolves to `ModuleBuilder.new`
* **Recommended builder order** (follow this in all new modules):
  1. `Module('Namespace', 'context')` — sets namespace and context (`server` | `client` | `shared`)
  2. `:mode('export'|'consumer_vm')` — optional, defaults to `'export'`
  3. `:exportAs('Prefix')` — optional, sets the public export prefix
  4. `:impl(ImplementationTable)` — required, table containing the functions to expose
  5. Optional flags — `:bind()`, `:callable()`, `:globalName('Name')`, `:hidden()`, `:testable(false)`
  6. `:methods(function(m) ... end)` — required, declares methods via `MethodsBuilder`
  7. `:build()` — required, finalizes and returns the `ModuleDeclaration` table
* **Support modules declare their exposure mode** via `ModuleDeclaration.mode`:
  - `mode = 'export'` (default) — stateless/static methods registered as FiveM exports
  - `mode = 'consumer_vm'` — source loaded directly into the consumer's Lua VM via `LoadResourceFile` + `load()`. Required for constructors returning objects with instance methods, because FiveM exports serialize return values and strip metatables
* `shared/types/` uses LuaLS `--- @meta` and is never executed at runtime
* **Adapters are split by context** — `framework/` has `_base_client.lua`, `_base_server.lua`, and `client/`, `server/` subdirectories
* **Fallback adapters** — every adapter category includes `_custom.lua` for user-defined overrides

---

## Call Flow Example

```
TSFX:Player(source):addMoney('bank', 5000)

init.lua
  └── features/player/facade.lua  :addMoney('bank', 5000)
        └── exports.tsfx_sdk:Player_giveMoney(source, 'bank', 5000)
              └── features/player/server.lua  → adapters/framework/server/esx.lua
                    → actual framework call
```

The facade talks to the server module via exports. The server module talks to the adapter. Adapters are the only layer that touches framework internals.
