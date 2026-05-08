# TSFX SDK — LuaLS Typing Conventions

All code in the SDK is typed via [Lua Language Server](https://luals.github.io/) annotations. This guide is mandatory reading for contributors and is enforced in CI.

---

## Table of Contents

1. [Core Rules](#core-rules)
2. [`@meta` — Type-Only Files](#meta--type-only-files)
3. [`@class` and `@field`](#class-and-field)
4. [`@alias` — Union / Literal Types](#alias--union--literal-types)
5. [`@enum` — Fixed Value Sets](#enum--fixed-value-sets)
6. [`@param` and `@return`](#param-and-return)
7. [`@generic` — Chainable & Generic Patterns](#generic--chainable--generic-patterns)
8. [`@type` — Local Variable Annotations](#type--local-variable-annotations)
9. [`@cast` — Explicit Type Assertions](#cast--explicit-type-assertions)
10. [Adapter Interface Contracts](#adapter-interface-contracts)
11. [Naming Conventions](#naming-conventions)
12. [Common Pitfalls](#common-pitfalls)
13. [PR Checklist](#pr-checklist)

---

## Core Rules

1. **Every public function** must have `@param` for every parameter and `@return` for every return value.
2. **Never declare methods in `shared/types/`** — type files contain `@class` with `@field` (state/properties) only. Functions are typed automatically by LuaLS from their implementation files.
3. **Type files are never executed** — they live in `shared/types/` and start with `--- @meta`. Do not add runtime logic or `return` statements.
4. **Use `@cast` or `@type` when inference fails** — do not leave variables untyped because LuaLS could not figure it out.
5. **Annotations use `---@` (no space)** — write `---@param`, not `--- @param`.

---

## `@meta` — Type-Only Files

Files in `shared/types/` exist solely for LuaLS. They are **not** listed in `fxmanifest.lua` and are never loaded at runtime.

### Required Header

```lua
--- @meta
```

Use exactly one space between `---` and `@meta`. This is the only annotation that keeps the space for readability consistency with the rest of the codebase.

### What Goes in Type Files

- `@class` definitions with `@field` declarations
- `@alias` definitions for union / literal types
- `@enum` definitions for fixed integer sets
- Module-level `@class` that re-export types consumed by other modules

### What Does **Not** Go in Type Files

- Function signatures (LuaLS infers these from implementation files)
- Runtime code (`print`, `exports`, native calls)
- `return` statements (except in implementation files)

### Example

```lua
--- @meta
-- Type definitions for TSFX Bridge Configuration
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class TSFXConfig
---@field framework 'auto'|'esx'|'qbcore'|'qbox'|'custom'
---@field inventory 'auto'|'ox_inventory'|'qs-inventory'|'ps-inventory'|'custom'
```

---

## `@class` and `@field`

Define all classes with `@class`. Document every piece of mutable state with `@field`.

### Class Definition Template

```lua
---@class ClassName
---@field _state string Current machine state
---@field _transitions table<string, StateMachineTransition> Map of valid transitions
ClassName = {}
ClassName.__index = ClassName
```

### Rules

- Use PascalCase for class names.
- Private fields start with `_` (e.g., `_listeners`, `_cache`).
- Document the type **and** a brief description on the same `@field` line.
- Do **not** add method declarations to the class in type files — LuaLS picks them up from the implementation.

### ❌ Wrong — Methods in Type File

```lua
-- shared/types/PlayerHandle.lua (WRONG)
---@class PlayerHandleClass
---@field _source number Player server ID
---@field GiveMoney fun(account: string, amount: number): PlayerHandleClass  -- DON'T
```

### ✅ Correct — Fields Only

```lua
-- shared/types/PlayerHandle.lua (CORRECT)
---@class PlayerHandleClass
---@field _source number Player server ID
---@field _adapter FrameworkAdapterClass Injected adapter reference
```

### ✅ Correct — Methods in Implementation

```lua
-- facades/PlayerHandle.lua
---@class PlayerHandleClass
PlayerHandle = {}
PlayerHandle.__index = PlayerHandle

---Give money to the player
---@param account string The account type ('cash', 'bank', etc.)
---@param amount number The amount to give
---@return PlayerHandleClass
function PlayerHandle:GiveMoney(account, amount)
    self._adapter:giveMoney(self._source, account, amount)
    return self
end
```

---

## `@alias` — Union / Literal Types

Use `@alias` when a parameter or field accepts a fixed set of string literals or when a type is a union of several concrete types.

### Literal Union

```lua
---@alias LogLevel 'debug' | 'info' | 'warn' | 'error'
```

### Complex Union

```lua
---@alias MoneyAccount 'bank' | 'cash' | 'black_money'
---@alias FrameworkName 'esx' | 'qbcore' | 'qbox' | 'custom'
```

### Type Shorthand

```lua
---@alias CacheValue string | number | boolean | table | nil
```

---

## `@enum` — Fixed Value Sets

Use `@enum` for integer-based constant sets (Lua 5.4 style). This is stricter than `@alias` for numeric values and gives better autocompletion.

```lua
---@enum PlayerState
local PlayerState = {
    CONNECTING = 0,
    ACTIVE = 1,
    DEAD = 2,
    DISCONNECTING = 3,
}
```

> **Note:** `@enum` generates a table type with literal keys. Use it for SDK-wide constants in `shared/constants.lua` or `shared/enums.lua` when those values are referenced by multiple modules.

---

## `@param` and `@return`

These are **mandatory** on every public function. Optional parameters are marked with `?`.

### Parameter Syntax

```lua
---@param name type Description
---@param name? type Optional parameter
```

### Return Syntax

```lua
---@return type Description
---@return type? Description for optional second return
---@return boolean success Whether the operation succeeded
---@return string? error Error message if success is false
```

### Example — Multiple Returns

```lua
---Attempt to transition to a new state
---@param to string Target state name
---@param context? table Optional context data to merge
---@return boolean success Whether the transition occurred
---@return string? error Reason if the transition was blocked
function StateMachine:transition(to, context)
    -- ...
    return true
end
```

### Private Helpers

Private local functions and methods should still be typed. Mark them `@private` when they are not part of the public API.

```lua
---Check if a cache entry has expired
---@private
---@param entry CacheEntry|nil
---@return boolean
local function isExpired(entry)
    -- ...
end
```

---

## `@generic` — Chainable & Generic Patterns

Most TSFX handles use chainable methods that return `self`. For simple classes, returning the concrete class name is sufficient:

```lua
---@return PlayerHandleClass
function PlayerHandle:GiveMoney(account, amount)
    -- ...
    return self
end
```

When a base class is extended or when a fluent builder is used, use `@generic` to preserve the exact subtype:

```lua
---@generic T : StateMachineBuilderClass
---@param self T
---@param transition StateMachineTransition
---@return T
function StateMachineBuilder:addTransition(transition)
    table.insert(self._transitions, transition)
    return self
end
```

This ensures that if `AdvancedBuilder` extends `StateMachineBuilder`, chaining `addTransition` still returns `AdvancedBuilder`, not the base type.

---

## `@type` — Local Variable Annotations

When LuaLS cannot infer a local variable's type, annotate it explicitly.

### Unknown Table Shape

```lua
---@type table<string, number>
local scores = json.decode(rawJson)
```

### Union or Literal

```lua
---@type 'server' | 'client'
local context = isServer() and 'server' or 'client'
```

### Class Instance from Dynamic Source

```lua
---@type LogInstance
local logger = LoggerRegistry.get(resourceName)
```

---

## `@cast` — Explicit Type Assertions

Use `@cast` when LuaLS knows a variable exists but has the wrong type, or when narrowing is needed after a runtime check.

### Narrowing After Runtime Check

```lua
local raw = transition.from

if type(raw) == 'table' then
    ---@cast raw string[]
    for _, state in ipairs(raw) do
        -- state is now typed as string
    end
else
    ---@cast raw string
end
```

### Fixing Inference in Complex Expressions

```lua
---@type string[]
local froms = type(transition.from) == 'table' and transition.from or { transition.from }
```

> **Use whichever pattern best fits the situation.** All three are valid LuaLS syntax:
>
> - `---@type T` on a variable declaration — cleanest for locals
> - `---@cast var T` after a runtime check — best for narrowing
> - `--[[@as T]]` inline — works inside expressions (e.g., `someFn(x --[[@as string]])`)
>
> The `--[[@as]]` syntax is an inline type assertion, not a block comment. It is valid and widely supported. Use it when an inline cast improves readability.

---

## Adapter Interface Contracts

Adapters implement a framework-agnostic interface defined in `_base.lua`. The base file declares the contract; each adapter file implements it.

### Base Interface (`_base.lua`)

```lua
---@class FrameworkAdapterClass
FrameworkAdapter = {}

---Give money to a player
---@param playerSrc number
---@param account MoneyAccount
---@param amount number
function FrameworkAdapter:giveMoney(playerSrc, account, amount) end

---Take money from a player
---@param playerSrc number
---@param account MoneyAccount
---@param amount number
---@return boolean success
function FrameworkAdapter:takeMoney(playerSrc, account, amount) end
```

### Implementation (`esx.lua`)

```lua
---@class ESXAdapter : FrameworkAdapterClass
ESXAdapter = {}
ESXAdapter.__index = ESXAdapter
setmetatable(ESXAdapter, { __index = FrameworkAdapter })

---@param playerSrc number
---@param account MoneyAccount
---@param amount number
function ESXAdapter:giveMoney(playerSrc, account, amount)
    local xPlayer = ESX.GetPlayerFromId(playerSrc)
    xPlayer.addAccountMoney(account, amount)
end
```

### Rules for Adapters

- The `_base.lua` file declares **all** methods with full `@param` / `@return` signatures, even if bodies are empty.
- Implementation files **re-declare `@class`** with inheritance (`: BaseClass`) and repeat the `@param` / `@return` annotations.
- Never omit `@return` on an adapter method just because the base declares it — LuaLS needs it on every implementation for precise hover info.

---

## Naming Conventions

| Construct | Convention | Example |
|-----------|------------|---------|
| Type files | `shared/types/<domain>.lua` | `shared/types/log.lua` |
| Class names | PascalCase, descriptive suffix | `PlayerHandleClass`, `EventBusClass` |
| Alias names | PascalCase, noun | `LogLevel`, `MoneyAccount` |
| Enum names | PascalCase, singular noun | `PlayerState` |
| Private fields | Leading underscore | `_listeners`, `_sessionTokens` |
| Function params | camelCase, descriptive | `playerSrc`, `callbackId` |

---

## Common Pitfalls

### ❌ Methods in `shared/types/`

```lua
-- shared/types/Log.lua (WRONG)
---@class LogInstance
---@field debug fun(msg: string)  -- DON'T
```

### ✅ Valid Type Assertion Patterns

All three patterns are valid. Pick whichever fits the situation.

**`@type` on a variable declaration:**
```lua
---@type string
local x = something
```

**`@cast` after a runtime check:**
```lua
if type(raw) == 'table' then
    ---@cast raw string[]
end
```

**`--[[@as]]` inline (useful inside expressions):**
```lua
local froms = type(t.from) == 'table' and t.from or { t.from --[[@as string]] } --[[@as string[]]]
```

### ❌ Missing `@return` on Chainable Methods

```lua
-- WRONG
function PlayerHandle:GiveMoney(account, amount)
    self._adapter:giveMoney(self._source, account, amount)
    return self  -- LuaLS infers as any without @return
end
```

### ✅ Always Declare Return Type

```lua
---@return PlayerHandleClass
function PlayerHandle:GiveMoney(account, amount)
    -- ...
    return self
end
```

### ❌ Omitting Optional Marker

```lua
-- WRONG — LuaLS thinks data is required
---@param data table
function LogInstance:debug(message, data)
```

### ✅ Mark Optional Parameters

```lua
---@param data table|nil
function LogInstance:debug(message, data)
```

---

## PR Checklist

Before opening a PR, verify:

- [ ] All new functions have `@param` for every parameter
- [ ] All new functions have `@return` for every return value
- [ ] No methods declared in `shared/types/` files (fields only)
- [ ] No invalid inline cast syntax (`--[[@as]]`)
- [ ] `@cast` or `@type` used where LuaLS cannot infer types
- [ ] Adapter methods match `_base.lua` contract exactly
- [ ] `fxmanifest.lua` updated only if new runtime files added (type files are **never** added)
- [ ] LuaLS reports **zero warnings** on changed files
