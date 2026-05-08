# TSFX Bridge SDK - Project Structure

This document defines the canonical structure for the TSFX Bridge SDK monorepo.

---

## Monorepo Root

This is a **pnpm monorepo** with a flat package layout.

```
tsfx_sdk/
├── resource/
├── extension/
├── scripts/
├── docs/
│   └── structure.md
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
├── init.lua                          ← TSFX global facade, context-aware routing
├── .luarc.json
│
├── shared/
│   ├── utils/
│   │   ├── context.lua               ← isServer(), isClient(), getContext()
│   │   └── manifest.lua              ← ManifestBuilder
│   ├── config.lua
│   ├── constants.lua
│   ├── enums.lua
│   └── types/                        ← LuaLS @meta only, never executed at runtime
│       ├── context.lua
│       ├── eventbus.lua
│       ├── exports.lua
│       ├── log.lua
│       └── statemachine.lua
│
├── support/                          ← Flat utility modules, no _index pattern
│   ├── EventBus.lua                  ← mode = 'export' (stateless, shared)
│   ├── LogInstance.lua               ← mode = 'consumer_vm' (per-resource logger)
│   ├── LoggerRegistry.lua            ← bridge-only, no manifest participation
│   ├── StateMachine.lua              ← mode = 'consumer_vm' (method-bearing objects)
│   ├── StateMachineBuilder.lua       ← mode = 'consumer_vm'
│   ├── Exports.lua
│   └── Cache.lua                     ← mode = 'export' (shared central cache)
│
├── adapters/                         ← Framework & inventory adapters (client + server)
│   ├── framework/
│   │   ├── _base.lua                 ← Adapter interface contract
│   │   ├── esx.lua
│   │   └── qbcore.lua
│   └── inventory/
│       ├── _base.lua
│       └── ox_inventory.lua
│
├── facades/                          ← Public API handles (what consuming devs touch)
│   ├── PlayerHandle.lua              ← Returned by TSFX:Player() — chainable, immediate execution
│   ├── VehicleHandle.lua
│   └── ...
│
├── server/
│   ├── modules/
│   │   └── PlayerService/            ← Owns server-side player session + state
│   │       ├── _index.lua
│   │       ├── events.lua
│   │       └── transitions.lua
│   ├── main.lua
│   └── exports.lua
│
├── client/
│   ├── modules/
│   │   └── PlayerModule/             ← Owns client-side local player state
│   │       ├── _index.lua
│   │       └── events.lua
│   ├── main.lua
│   └── exports.lua
│
└── CHANGELOG.md
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
    └── utils/
        ├── paths.ts
        └── server.ts
```

---

## `extension/` — VSCode Extension (stub, unscoped)

```
extension/
├── package.json
└── README.md
```

---

## Architectural Layers

| Layer | Folder | Consumed by |
| -- | -- | -- |
| Public API routing | `init.lua` | Consuming devs (`TSFX:Player()`) |
| Chainable handles | `facades/` | `init.lua` — instantiated per call |
| Business logic | `server/modules/`, `client/modules/` | `main.lua`, `exports.lua` |
| Framework translation | `adapters/` | Modules + facades via injected adapter ref |
| SDK utilities | `support/` | Everything internally |
| Shared contracts | `shared/types/` | LuaLS only — never runtime |

---

## Key Conventions

* **No** `_internal/` injection — support modules are first-class in this resource
* **No ORM-style** `Get()`/`Save()` — facade methods execute immediately and return `self` for chaining
* **Adapters are not server-only** — `adapters/` lives at resource root, loaded per context as needed
* `init.lua` is the public API entry point — loaded by consuming resources via `@tsfx_sdk/init.lua`, not listed in fxmanifest
* `server/main.lua` and `client/main.lua` are the resource's own bootstrap, loaded by fxmanifest
* **Support modules are flat files** — no `_index.lua` folder pattern. They have a **dual responsibility**: define their global class (for runtime use) AND return a `ModuleDeclaration` table (for the manifest builder)
* **Support modules declare their exposure mode** via `ModuleDeclaration.mode`:
  - `mode = 'export'` (default) — stateless/static methods registered as FiveM exports
  - `mode = 'consumer_vm'` — source loaded directly into the consumer's Lua VM via `LoadResourceFile` + `load()`. Required for constructors returning objects with instance methods, because FiveM exports serialize return values and strip metatables
* `shared/types/` uses LuaLS `--- @meta` and is never executed at runtime

---

## Call Flow Example

```
TSFX:Player(source):GiveMoney('bank', 5000)

init.lua
  └── facades/PlayerHandle.lua  :GiveMoney('bank', 5000)
        └── adapters/framework/
              └── esx.lua / qbcore.lua  → actual framework call
```

The handle talks directly to the adapter — not to a module. Modules own state and respond to events but are not in the call path for simple facade methods.
