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

- **`resource/`** — The FiveM resource (`tsfx_sdk`). Contains all runtime code, facades, adapters, modules, and support utilities.
- **`scripts/`** — Plain dev tooling folder (not a pnpm package). Contains TypeScript build scripts run from repo root.
- **`extension/`** — VSCode extension stub (unscoped, future development).
- **Root-level config files** — Define workspace-wide settings, dependencies, and tooling.

### Package Boundaries

- `resource/` and `extension/` are declared as pnpm workspace packages
- `scripts/` is NOT a package — it is a plain folder with its own `package.json` for dependency management but is not part of the workspace

## Architectural Layers

The SDK is organized into strict architectural layers. **Never cross these boundaries** — respect the separation of concerns:

| Layer | Folder | Responsibility |
|-------|--------|--------------|
| Public API | `init.lua` | Declares the `TSFX` global, routes calls to facades by context (server/client) |
| Facades | `facades/` | Chainable handle objects — the surface consuming devs touch |
| Modules | `server/modules/`, `client/modules/` | Own state, respond to events, contain business logic |
| Adapters | `adapters/` | Translate SDK calls to framework-specific implementations |
| Support | `support/` | Internal SDK utilities (EventBus, Log, StateMachine, etc.) |
| Shared contracts | `shared/types/` | LuaLS `@meta` type declarations — never executed at runtime |

### Layer Rules

- Facades talk to adapters, not directly to modules
- Modules own state and respond to events via EventBus
- Adapters are the only layer that knows about framework-specific implementations
- Support modules are utilities used across all layers

## The TSFX Facade (`init.lua`)

- `init.lua` is the public API entry point
- It is loaded by consuming resources via `@tsfx_sdk/init.lua` — **it is NOT listed in `fxmanifest.lua`**
- It declares the global `TSFX` table and routes method calls to the correct facade based on `IsDuplicityVersion()`
- Consuming devs **never** call exports directly — everything goes through `TSFX`

### Usage Pattern

```lua
-- Server-side: pass player source
TSFX:Player(source):GiveMoney('bank', 5000):TakeItem('bread', 1)

-- Client-side: no source needed for local player
TSFX:Player():ShowNotification('Hello!')
```

## Chainable Handle Pattern

Facade handles use a chainable API pattern with these strict rules:

- **Methods execute immediately** — there is no deferred/ORM-style queuing
- **Every method returns `self`** to allow chaining
- **The chain is purely ergonomic** — each call is an independent operation
- **Handles are instantiated per call** to `TSFX:Player()` etc., not cached singletons

### Implementation Template

```lua
---@class PlayerHandleClass
---@field _source number The player server ID
---@field _adapter FrameworkAdapterClass The injected framework adapter
PlayerHandle = {}
PlayerHandle.__index = PlayerHandle

function PlayerHandle:GiveMoney(account, amount)
    self._adapter:giveMoney(self._source, account, amount)
    return self
end
```

## Adapter Conventions

Adapters provide framework-specific implementations behind a common interface:

- **`_base.lua`** in each adapter category defines the interface contract all adapters must implement
- **Adapters are NOT server-only** — `adapters/` lives at resource root and may be loaded in either context
- **Facades receive an injected adapter reference** — they never detect the framework themselves
- **Adapter method names use camelCase** and must match the `_base.lua` interface exactly

### Adapter Structure

```
adapters/
├── framework/
│   ├── _base.lua          -- Interface contract
│   ├── esx.lua            -- ESX implementation
│   └── qbcore.lua         -- QBCore implementation
└── inventory/
    ├── _base.lua
    └── ox_inventory.lua
```

## Module Conventions

Modules follow a strict folder pattern with clear separation of definition, events, and transitions:

1. **Modules are folders** with `_index.lua`, and optionally `events.lua` and `transitions.lua`
2. **`_index.lua`** defines the class — no side effects, pure definition
3. **`events.lua`** contains a `registerEvents(service)` function called from `_index.lua` `:init()`
4. **`transitions.lua`** contains a `registerTransitions(builder, service)` function called from `_index.lua`
5. **`main.lua`** is the only place modules are instantiated and wired — no business logic here
6. **`exports.lua`** is the only place exports are registered
7. Modules use EventBus and Log from `support/` — never raw FiveM functions directly

### Module Template

```lua
-- modules/MyService/_index.lua
---@class MyServiceClass
MyService = {}
MyService.__index = MyService

function MyService.new()
    local self = setmetatable({}, MyService)
    return self
end

function MyService:init()
    registerEvents(self)
    -- Additional initialization
end

-- modules/MyService/events.lua
function registerEvents(service)
    EventBus:on('playerJoined', function(data)
        service:handlePlayerJoin(data.source)
    end)
end
```

## Support Module Conventions

Support modules (`support/`) provide internal utilities:

- **Support modules are flat files** — no `_index.lua` folder pattern
- They are simple utilities with no events or state machines of their own
- They are loaded via `shared_scripts` in `fxmanifest.lua` and available as globals in both contexts
- **Do not add folder-based modules to `support/`** — keep it flat

### Support Files

```
support/
├── EventBus.lua
├── Log.lua
├── StateMachine.lua
├── StateMachineBuilder.lua
├── Exports.lua
└── Cache.lua
```

## FiveM Lua Rules

FiveM's Lua environment has specific constraints:

- **No `require()`** — All scripts are loaded via `fxmanifest.lua` load order
- **Globals are automatically in scope** — Files loaded earlier can be accessed from later files
- **Do NOT `return` at the end of module files** — Globals are the export mechanism
- **Do NOT reassign globals in `main.lua`** — They are already available from load order

### Load Order (fxmanifest.lua)

```lua
shared_scripts {
    -- 1. Type definitions (not executed)
    'shared/types/*.lua',
    -- 2. Shared configuration
    'shared/config.lua',
    'shared/constants.lua',
    'shared/enums.lua',
    -- 3. Support utilities
    'support/*.lua',
    -- 4. Adapters (framework abstraction)
    'adapters/framework/_base.lua',
    'adapters/framework/*.lua',
    'adapters/inventory/_base.lua',
    'adapters/inventory/*.lua',
    -- 5. Facades (public API handles)
    'facades/*.lua',
}

server_scripts {
    -- 6. Server modules
    'server/modules/**/*_index.lua',
    'server/modules/**/*.lua',
    -- 7. Server bootstrap
    'server/main.lua',
    'server/exports.lua',
}

client_scripts {
    -- 6. Client modules
    'client/modules/**/*_index.lua',
    'client/modules/**/*.lua',
    -- 7. Client bootstrap
    'client/main.lua',
    'client/exports.lua',
}
```

## LuaLS Type Annotations

All Lua code must use consistent Lua Language Server annotations:

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

-- support/Log.lua (implementation file)
---@param msg string The message to log
function LogInstance:debug(msg)
    self:log('debug', msg)
end
```

Adding functions to types causes LuaLS warnings because the functions are already defined in the actual module files.

### Annotation Template

```lua
---@class PlayerHandleClass
---@field _source number The player server ID
---@field _adapter FrameworkAdapterClass The injected framework adapter
PlayerHandle = {}
PlayerHandle.__index = PlayerHandle

---Create a new player handle
---@param source number The player server ID
---@param adapter FrameworkAdapterClass The framework adapter instance
---@return PlayerHandleClass
function PlayerHandle.new(source, adapter)
    local self = setmetatable({}, PlayerHandle)
    self._source = source
    self._adapter = adapter
    return self
end

---Give money to the player
---@param account string The account type ('cash', 'bank', etc.)
---@param amount number The amount to give
---@return PlayerHandleClass
function PlayerHandle:GiveMoney(account, amount)
    self._adapter:giveMoney(self._source, account, amount)
    return self
end
```

## No External Dependencies

The SDK must remain dependency-free:

- **Never use `lib` (ox_lib)** or other external libraries in the SDK itself
- Only use: FiveM native functions, `support/` APIs, and resource-specific utilities
- The SDK *wraps* external frameworks via adapters — it does not depend on them directly outside of adapter files

## Naming Conventions

Consistent naming improves readability and maintainability:

- `playerSrc` — server-side player server ID
- `playerId` — client-side local player ID (`PlayerId()`)
- `<relationship>Src` — other players' server IDs (e.g., `targetSrc`)
- **Handle classes** use PascalCase with `Handle` suffix: `PlayerHandle`, `VehicleHandle`
- **Adapter implementations** use PascalCase with framework prefix: `ESXAdapter`, `QBCoreAdapter`
- **Support modules** use PascalCase: `EventBus`, `Log`, `StateMachine`

## Clean Code Practices

Maintain high code quality:

- **Remove unused variables** — no placeholder parameters
- **Use descriptive names** — avoid single-letter variables except in loops
- **Keep functions focused** — one responsibility per function
- **Metatable pattern must be consistent** across all modules — do not mix singleton and instantiated patterns

### Code Review Checklist

Before submitting changes:

- [ ] All new functions have proper LuaLS annotations
- [ ] No unused variables or parameters
- [ ] No mixing of singleton and instance patterns
- [ ] No direct framework calls outside of adapters
- [ ] All globals properly declared before use
- [ ] Load order in fxmanifest.lua updated if new files added
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
