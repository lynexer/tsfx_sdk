# TSFX Bridge SDK — AI Agent Rules

This document defines conventions and best practices for AI agents working on the TSFX Bridge SDK repository.

## External File Loading

CRITICAL: When you encounter a file reference (e.g. @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

Instructions:

- Do NOT preemptively load all references - use lazy loading based on actual need
- When loaded. treat content as mandatory instructions that override defaults
- Follow references recursively when needed

## Monorepo Structure

This is a flat pnpm monorepo with the following layout:

- **`resource/`** — The FiveM resource (`tsfx_sdk`). Contains all runtime code, features, adapters, core services, and shared contracts.
- **`scripts/`** — Plain dev tooling folder (not a pnpm package). Contains TypeScript build scripts run from repo root.
- **Root-level config files** — Define workspace-wide settings, dependencies, and tooling.

### Package Boundaries

- `resource/` is declared as a pnpm workspace package
- `scripts/` is NOT a package — it is a plain folder with its own `package.json` for dependency management but is not part of the workspace

## Architectural Layers

The SDK is organized into strict architectural layers. **Never cross these boundaries** — respect the separation of concerns:

| Layer | Folder | Responsibility |
|-------|--------|--------------|
| Public API | `init.lua` | Declares the `TSFX` global, builds facade from manifest metadata, loads core utilities into consumer VM |
| Features | `features/` | Chainable facade handles + feature modules — the surface consuming devs touch |
| Adapters | `adapters/` | Translate SDK calls to framework-specific implementations |
| Core | `core/` | Internal SDK utilities (EventBus, Log, Cache, ManifestBuilder, ModuleBuilder, etc.) |
| Shared contracts | `shared/types/` | LuaLS `@meta` type declarations — never executed at runtime |

### Layer Rules

- Feature facades talk to adapters indirectly via exports, not directly to feature modules
- Feature modules own state and respond to events via EventBus
- Adapters are the only layer that knows about framework-specific implementations
- Core services are utilities used across all layers

## The TSFX Facade (`init.lua`)

- `init.lua` is the public API entry point
- It is loaded by consuming resources via `@tsfx_sdk/init.lua` — **it is NOT listed in `fxmanifest.lua`**
- It bootstraps the consumer VM by loading `core/utils/context.lua`, `core/utils/module_builder.lua`, `core/services/facade_base.lua`, `shared/constants.lua`, and `core/services/log_instance.lua`
- It consumes `GetFacadeManifest()` export to bind modules into the `TSFX` global
- Consuming devs **never** call exports directly — everything goes through `TSFX`

### Usage Pattern

```lua
-- Server-side: pass player source
TSFX:Player(source):addMoney('bank', 5000)

-- Client-side: no source needed for local player
TSFX:Player():getPosition()
```

## Chainable Handle Pattern

Facade handles use a chainable API pattern with these strict rules:

- **Methods execute immediately** — there is no deferred/ORM-style queuing
- **Every method returns `self`** to allow chaining
- **The chain is purely ergonomic** — each call is an independent operation
- **Handles are instantiated per call** to `TSFX:Player()` etc., not cached singletons
- **Facades extend `Facade` base class** — use `_serverOnly` and `_clientOnly` guards for context-restricted methods

### Implementation Template

```lua
---@class PlayerHandleClass : FacadeClass
PlayerHandle = setmetatable({}, { __index = Facade })
PlayerHandle.__index = PlayerHandle

---@param playerSrc? number
---@return PlayerHandleClass
function PlayerHandle.new(playerSrc)
    local self = setmetatable({}, PlayerHandle)
    self._class = 'PlayerHandle'
    self.source = playerSrc
    return self
end

---Add money to the player
---@param account MoneyAccount
---@param amount number
---@return PlayerHandleClass
function PlayerHandle:addMoney(account, amount)
    return self:_serverOnly('addMoney', function()
        self._export:Player_giveMoney(self.source, account, amount)
        return self
    end, self)
end
```

## Adapter Conventions

Adapters provide framework-specific implementations behind a common interface:

- **`_base.lua`** in each adapter category defines the interface contract all adapters must implement
- **Framework adapters are split by context** — `adapters/framework/client/` and `adapters/framework/server/` each have `_base_<context>.lua`
- **Fallback adapters** — each category includes `_custom.lua` for user-defined overrides
- **Adapters are NOT server-only** — `adapters/` lives at resource root and may be loaded in either context
- **Facades call exports** — they do not hold injected adapter references; the server-side feature module binds to the adapter
- **Adapter method names use camelCase** and must match the `_base.lua` interface exactly

### Adapter Structure

```
adapters/
├── framework/
│   ├── _base_client.lua   -- Client interface contract
│   ├── _base_server.lua   -- Server interface contract
│   ├── client/
│   │   ├── esx.lua
│   │   ├── qbcore.lua
│   │   └── qbox.lua
│   └── server/
│       ├── esx.lua
│       ├── qbcore.lua
│       └── qbox.lua
├── inventory/
│   ├── _base.lua
│   ├── _custom.lua
│   ├── ox_inventory.lua
│   └── ps-inventory.lua
├── notify/
│   ├── _base.lua
│   ├── esx.lua
│   ├── ox_lib.lua
│   └── qb.lua
└── ... (dispatch, fuel, interact, keys, medical, phone, progress)
```

## Feature Conventions

Features follow a folder pattern with clear separation of facade, server logic, client logic, and shared logic:

1. **Features are folders** under `features/` (e.g., `features/player/`)
2. **`facade.lua`** — chainable handle class, consumer_vm mode, extends `Facade`
3. **`server.lua`** — server-side export module (hidden), talks to adapter
4. **`client.lua`** — client-side export module (hidden)
5. **`shared.lua`** — shared export module used by both contexts
6. **`main.lua`** is the only place features are loaded — no business logic here
7. Features use EventBus and Log from `core/` — never raw FiveM functions directly

### Feature Template

```lua
-- features/MyFeature/facade.lua
---@class MyFeatureHandleClass : FacadeClass
MyFeatureHandle = setmetatable({}, { __index = Facade })
MyFeatureHandle.__index = MyFeatureHandle

function MyFeatureHandle.new()
    local self = setmetatable({}, MyFeatureHandle)
    self._class = 'MyFeatureHandle'
    return self
end

function MyFeatureHandle:doThing()
    self._export:MyFeature_doThing()
    return self
end

return Module('MyFeature', 'shared')
    :mode('consumer_vm')
    :globalName('MyFeatureHandle')
    :callable()
    :build()

-- features/MyFeature/server.lua
MyFeatureModule = {}
MyFeatureModule.__index = MyFeatureModule

function MyFeatureModule.doThing()
    -- adapter call
end

return Module('MyFeature', 'server')
    :mode('export')
    :exportAs('MyFeature')
    :impl(MyFeatureModule)
    :hidden()
    :methods(function(m)
        m:add('doThing')
    end)
    :build()
```

## Core Service Conventions

Core services (`core/`) provide internal utilities:

- **`core/services/`** — runtime services (EventBus, Cache, Log, Await, Tick, Exports, FacadeBase)
- **`core/utils/`** — builder/registration utilities (Context, ManifestBuilder, ModuleBuilder, AdapterRegistry)
- Core files that participate in the manifest have a **dual responsibility**:
  define their global class (for runtime use) AND return a `ModuleDeclaration`
  built via `ModuleBuilder` (for the manifest builder)
- Use the `ModuleBuilder` API to declare modules — never hand-write the
  `ModuleDeclaration` table. The global alias `Module` is available in module
  files and resolves to `ModuleBuilder.new`
- **Recommended builder order** (follow this in all new modules):
  1. `Module('Namespace', 'context')` — sets namespace and context (`server` | `client` | `shared`)
  2. `:mode('export'|'consumer_vm')` — optional, defaults to `'export'`
  3. `:exportAs('Prefix')` — optional, sets the public export prefix
  4. `:impl(ImplementationTable)` — required, table containing the functions to expose
  5. Optional flags — `:bind()`, `:callable()`, `:globalName('Name')`, `:hidden()`, `:testable(false)`
  6. `:methods(function(m) ... end)` — required, declares methods via `MethodsBuilder`
  7. `:build()` — required, finalizes and returns the `ModuleDeclaration` table
- **`:bind()`** (formerly `:preloaded()`) marks a module for auto-binding to `_TSFX`
- **`ModuleDeclaration.mode`** controls how the module is exposed:
  - `mode = 'export'` (default) — methods are registered as FiveM exports and
    wrapped by `init.lua`. Safe for stateless/static methods.
  - `mode = 'consumer_vm'` — source is loaded directly into the consumer's Lua
    VM via `LoadResourceFile` + `load()`. Required for constructor methods that
    return objects with instance methods, because FiveM exports serialize return
    values and strip metatables.
- **Dependencies between consumer_vm modules:** If a consumer_vm module
  references internal globals (e.g., `_TSFX.Log`) that are set up by another
  module, init.lua pre-loads the dependency before iterating the manifest.
- **Do not add folder-based modules to `core/`** — keep `services/` and `utils/` flat

### Builder Example

```lua
---@class MyServiceClass
MyService = {}
MyService.__index = MyService

function MyService.new()
    local self = setmetatable({}, MyService)
    return self
end

function MyService:doThing()
    -- implementation
end

return Module('MyService', 'shared')
    :mode('consumer_vm')
    :exportAs('MyService')
    :impl(MyService)
    :methods(function(m)
        m:add('doThing')
    end)
    :build()
```

### Core Files

```
core/
├── services/
│   ├── event_bus.lua          -- mode = 'export' (stateless, shared)
│   ├── event_bus_facade.lua   -- mode = 'consumer_vm'
│   ├── cache.lua              -- mode = 'export'
│   ├── await.lua              -- mode = 'export'
│   ├── tick.lua               -- mode = 'export'
│   ├── log_instance.lua       -- mode = 'consumer_vm'
│   ├── exports.lua            -- mode = 'export'
│   └── facade_base.lua        -- mode = 'consumer_vm'
└── utils/
    ├── context.lua            -- isServer(), isClient(), getContext()
    ├── manifest.lua           -- ManifestBuilder
    ├── module_builder.lua     -- ModuleBuilder + MethodsBuilder
    └── adapter_registry.lua   -- AdapterRegistry
```

## FiveM Lua Rules

FiveM's Lua environment has specific constraints:

- **No `require()`** — All scripts are loaded via `fxmanifest.lua` load order
- **Globals are automatically in scope** — Files loaded earlier can be accessed from later files
- **Do NOT `return` at the end of module files** — Globals are the export mechanism
  - **Exception:** `core/*.lua` and feature files that participate in the manifest
    MUST return a `ModuleDeclaration` built via `ModuleBuilder` as their final
    statement. Use `return Module('Namespace', 'context')...:build()`. The global
    class definition and the returned declaration coexist.
- **Do NOT reassign globals in `main.lua`** — They are already available from load order

### Load Order (fxmanifest.lua)

```lua
shared_scripts {
    'core/utils/*.lua',
    'core/services/log_instance.lua',
    'shared/adapters.lua',
    'shared/config.lua',
    'shared/constants.lua',
    'shared/enums.lua',
    'adapters/**/*.lua'
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

files {
    'init.lua',
    'core/**/*.lua',
    'features/**/*.lua',
    'shared/**/*.lua'
}
```

## LuaLS Type Annotations

All Lua code must use consistent Lua Language Server annotations. See `docs/typing-conventions.md` for the complete, authoritative guide.

Quick reference:

- **`shared/types/` files use `--- @meta`** at the top and are **never listed in `fxmanifest.lua`**
- Use `@field` annotations on class definitions — not separate `@type` annotations on properties
- **Do NOT add function declarations to `shared/types/`** — functions defined in modules are automatically typed by LuaLS
- Only register **fields** (state/properties) in the shared types, never methods
- Use `@class`, `@param`, `@return` consistently throughout

### Type Definition Rule

**Functions belong in the module implementation, NOT in the types file.**

❌ **Wrong:** Adding method declarations to types
```lua
-- shared/types/Log.lua (types file)
---@class LogInstance
---@field level string Current log level
---@field debug fun(msg: string)  -- DON'T DO THIS
function LogInstance:debug(msg)  -- DON'T DO THIS
```

✅ **Correct:** Only fields in types, functions in implementation
```lua
-- shared/types/Log.lua (types file)
---@class LogInstance
---@field level string Current log level

-- core/services/log_instance.lua (implementation file)
---@param msg string The message to log
function LogInstance:debug(msg)
    self:log('debug', msg)
end
```

Adding functions to types causes LuaLS warnings because the functions are already defined in the actual module files.

### Annotation Template

```lua
---@class PlayerHandleClass : FacadeClass
---@field source number? The player server ID
---@field citizenId string The player's citizen ID
---@field isOnline boolean Whether the player is online
PlayerHandle = setmetatable({}, { __index = Facade })
PlayerHandle.__index = PlayerHandle

---Create a new player handle
---@param playerSrc? number The player server ID
---@return PlayerHandleClass
function PlayerHandle.new(playerSrc)
    local self = setmetatable({}, PlayerHandle)
    self._class = 'PlayerHandle'
    self.source = playerSrc
    self.citizenId = ''
    self.isOnline = true
    return self
end

---Add money to the player
---@param account string The account type ('cash', 'bank', etc.)
---@param amount number The amount to add
---@return PlayerHandleClass
function PlayerHandle:addMoney(account, amount)
    return self:_serverOnly('addMoney', function()
        self._export:Player_giveMoney(self.source, account, amount)
        return self
    end, self)
end
```

## No External Dependencies

The SDK must remain dependency-free:

- **Never use `lib` (ox_lib)** or other external libraries in the SDK itself
- Only use: FiveM native functions, `core/` APIs, and resource-specific utilities
- The SDK *wraps* external frameworks via adapters — it does not depend on them directly outside of adapter files

## Naming Conventions

Consistent naming improves readability and maintainability:

- `playerSrc` — server-side player server ID
- `playerId` — client-side local player ID (`PlayerId()`)
- `<relationship>Src` — other players' server IDs (e.g., `targetSrc`)
- **Handle classes** use PascalCase with `Handle` suffix: `PlayerHandle`, `VehicleHandle`
- **Adapter implementations** use PascalCase with framework prefix: `ESXAdapter`, `QBCoreAdapter`
- **Core services** use PascalCase: `EventBus`, `LogInstance`, `ManifestBuilder`
- **Feature modules** use `<Feature>Module` (e.g., `FrameworkModule`, `PlayerModule`)

## File Header and Section Separators

All new or significantly modified Lua files must follow these formatting conventions.

### File Headers

Use a `--[[ ... --]]` block at the top of every file. The first line uses either `MODULE:` or `ANCHOR:` prefix followed by `TSFX SDK - <Name>`. Subsequent lines are a concise description.

```lua
--[[
    MODULE: TSFX SDK - Module Name

    Description of what this file does.
--]]
```

Use `MODULE:` for files that define or implement a class/module. Use `ANCHOR:` for configuration or registry files that wire things together declaratively.

### Section Separators

Use section markers to group related declarations within large files.

```lua
-- SECTION: Section Name // ----------------------------------------

-- code here

-- !SECTION
```

When transitioning directly between sections, stack them:

```lua
-- !SECTION

-- SECTION: Next Section // ----------------------------------------
```

- Every section must end with `-- !SECTION`
- Section names use Title Case
- Leave one blank line after `-- !SECTION` when starting the next section

## Clean Code Practices

Maintain high code quality:

- **Remove unused variables** — no placeholder parameters
- **Use descriptive names** — avoid single-letter variables except in loops
- **Keep functions focused** — one responsibility per function
- **Metatable pattern must be consistent** across all modules — do not mix singleton and instantiated patterns

### Code Review Checklist

Before submitting changes:

- [ ] All new functions have proper LuaLS annotations (`@param` for every parameter, `@return` for every return value)
- [ ] No methods declared in `shared/types/` files — fields only
- [ ] Type assertions used where LuaLS cannot infer types (`@type`, `@cast`, or `--[[@as]]`)
- [ ] Adapter methods match `_base.lua` contract exactly
- [ ] No unused variables or parameters
- [ ] No mixing of singleton and instance patterns
- [ ] No direct framework calls outside of adapters
- [ ] All globals properly declared before use
- [ ] Load order in fxmanifest.lua updated if new runtime files added (type files are **never** added)
- [ ] Use EventBus for all network events (never native handlers)
- [ ] No indentation on empty lines

## AI Agent Conventions

### Always Use EventBus for Network Events

**Never use native FiveM event handlers directly.** Always use the EventBus for both registering and triggering network events:

❌ **Wrong:**
```lua
RegisterNetEvent('myevent', handler)
TriggerServerEvent('myevent', payload)
TriggerClientEvent('myevent', target, payload)
```

✅ **Correct:**
```lua
-- Registration with optional rate limiting
EventBus.register('myevent', 10, 1000)  -- 10 calls per 1000ms per player
EventBus.on('myevent', handler)

-- Triggering
EventBus.emitNet('myevent', payload)           -- client → server
EventBus.emitNet('myevent', target, payload)   -- server → client
EventBus.broadcast('myevent', payload)         -- server → all clients
```

### No Indentation on Empty Lines

Empty lines within code blocks must have zero indentation:

❌ **Wrong:**
```lua
if condition then
    doSomething()
    
    doSomethingElse()
end
```

✅ **Correct:**
```lua
if condition then
    doSomething()

    doSomethingElse()
end
```

This applies to all indentation styles (spaces or tabs).

### Always Comment on Linear Issues

After working on any Linear issue, you **must** post a comment tracking what progress was made:

**Required for every work session:**
- What was completed
- What remains
- Any blockers or questions
- Next steps

This ensures traceability and keeps the team informed of ongoing work.

### Never Commit to Git

AI agents **must not** run `git commit`, `git push`, or any other git write operations. All changes are left in the working tree for the user to review, stage, and commit themselves.

**What agents do:**
- Edit files and leave changes unstaged
- Optionally run `git status` or `git diff` to show the user what changed
- Stage files (`git add`) only if explicitly requested by the user

**What agents never do:**
- `git commit` (even with "suggested" messages)
- `git push`
- `git merge`, `git rebase`, or branch manipulation
- Force-pushing or rewriting history
