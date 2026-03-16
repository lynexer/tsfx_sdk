# TSFX Bridge SDK

A FiveM SDK providing a unified, chainable API for cross-framework resource development.

## Overview

TSFX Bridge SDK abstracts framework-specific implementations (ESX, QBCore, etc.) behind a consistent, chainable facade API. Consuming resources interact with `TSFX` global methods rather than calling framework exports directly.

## Installation

```bash
# Clone the repository
git clone https://github.com/tsfx/tsfx_sdk.git

# Install dependencies
pnpm install
```

## Basic Usage

Consuming resources load the SDK via `fxmanifest.lua`:

```lua
-- In your resource's fxmanifest.lua
shared_scripts {
    '@tsfx_sdk/init.lua'
}
```

Then use the chainable API:

```lua
-- Server-side
TSFX:Player(source):GiveMoney('bank', 5000):TakeItem('bread', 1)

-- Client-side
TSFX:Player():ShowNotification('Hello from TSFX!')
```

## Documentation

- [Project Structure](docs/structure.md) - Full monorepo and resource architecture
- [AGENTS.md](AGENTS.md) - AI agent rules and conventions for this repository

## License

MIT - See [LICENSE](LICENSE) for details.
