--- @meta
-- Public API type definitions for the TSFX global.
-- This file is NOT loaded at runtime — only for LuaLS type checking in consuming resources.

---@class PlayerHandleClass
---@field source number
---@field citizenId string
---@field isOnline boolean
---@field getPed fun(self): integer
---@field getPlayerId fun(self): number
---@field getModel fun(self): integer
---@field getHeading fun(self): number
---@field setHeading fun(self, heading: number): PlayerHandleClass
---@field getPosition fun(self): vector4
---@field setPosition fun(self, position: vector3|vector4, deadFlag?: boolean, ragdollFlag?: boolean, clearArea?: boolean): PlayerHandleClass
---@field getMoney fun(self, account: MoneyAccount): number
---@field addMoney fun(self, account: MoneyAccount, amount: number): PlayerHandleClass
---@field removeMoney fun(self, account: MoneyAccount, amount: number): PlayerHandleClass
---@field setMoney fun(self, account: MoneyAccount, amount: number): PlayerHandleClass
---@field getJob fun(self): JobData
---@field setJob fun(self, identifier: string, grade: number): PlayerHandleClass
---@field hasJob fun(self, identifier: string): boolean
---@field isOnDuty fun(self): boolean
---@field setDuty fun(self, onDuty: boolean): PlayerHandleClass
---@field getGang fun(self): GangData?
---@field setGang fun(self, identifier: string, grade: number): PlayerHandleClass
---@field getIdentity fun(self): IdentityData
---@field getIdentifiers fun(self): IdentifierData
---@field getMetadata fun(self, key: string): any
---@field setMetadata fun(self, key: string, value: any): PlayerHandleClass
---@field removeMetadata fun(self, key: string): PlayerHandleClass
---@field getVehicle fun(self, lastVehicle?: boolean): number
---@field getVehicleType fun(self, lastVehicle?: boolean): string
---@field isInVehicle fun(self, atGetIn?: boolean): boolean
---@field getVehicleSeat fun(self): number
---@field isDead fun(self): boolean
---@field isDriver fun(self): boolean
---@field isInWater fun(self): boolean
---@field isOnFoot fun(self): boolean
---@field isFrozen fun(self): boolean
---@field setFrozen fun(self, toggle: boolean): PlayerHandleClass
---@field isVisible fun(self): boolean
---@field isInvincible fun(self): boolean
---@field isRagdolling fun(self): boolean
---@field isSprinting fun(self): boolean
---@field isClimbing fun(self): boolean
---@field isDiving fun(self): boolean
---@field isSwimming fun(self): boolean
---@field isTalking fun(self): boolean
---@field isAiming fun(self): boolean
---@field isShooting fun(self): boolean
---@field isReloading fun(self): boolean
---@field playAnimation fun(self, animationDictionary: string, animationName: string, options?: AnimationOptions): PlayerHandleClass
---@field stopAnimation fun(self, animationDictionary: string, animationName: string, animationExitSpeed?: number): PlayerHandleClass
---@field isPlayingAnimation fun(self, animationDictionary: string, animationName: string, isSynchronizedScene?: boolean): boolean
---@field clearTasks fun(self): PlayerHandleClass
---@field getRoutingBucket fun(self): integer
---@field setRoutingBucket fun(self, bucket: integer): PlayerHandleClass
---@field notify fun(self): PlayerHandleClass
---@field drop fun(self, reason: string): PlayerHandleClass
---@field is fun(self, query: string|table): boolean

---@class InventoryHandleClass
---@field giveItem fun(source: number, item: string, count: number, metadata?: table)
---@field removeItem fun(source: number, item: string, count: number): boolean
---@field hasItem fun(source: number, item: string, count?: number): boolean
---@field getItem fun(source: number, item: string): ItemData?
---@field getInventory fun(source: number): ItemData[]

---@class NotifyHandleClass
---@field send fun(source: number, message: string, type: string, duration: number)
---@field progressStart fun(source: number, params: table)
---@field progressCancel fun(source: number)

---@class FrameworkHandleClass
---@field GetAllJobs fun(self): { [string]: JobDefinition }
---@field GetJobDefinition fun(self, name: string): JobDefinition?
---@field GetAllGangs fun(self): { [string]: GangDefinition }
---@field GetGangDefinition fun(self, name: string): GangDefinition?
---@field GetName fun(self): string
---@field GetVersion fun(self): string?
---@field FindPlayer fun(self, idType: string, value: string): number?
---@field FindPlayerByCitizenId fun(self, citizenId: string): number?
---@field HasGangs fun(self): boolean

---@class CacheClass
---@field get fun(key: string): any
---@field set fun(key: string, value: any, ttl?: number)
---@field has fun(key: string): boolean
---@field delete fun(key: string)
---@field flush fun()

---@class LocaleClass
---@field get fun(key: string, params?: table): string, table?
---@field getLanguage fun(): string?
---@field getLanguageGTA fun(): string?
---@field reload fun()

---@class StreamingClass
---@field requestModel fun(asset: string|number, timeout?: number): StreamingHandle
---@field withModel fun(asset: string|number, fn: fun(asset: number|string), timeout?: number)
---@field requestAnimDict fun(asset: string, timeout?: number): StreamingHandle
---@field withAnimDict fun(asset: string, fn: fun(asset: string), timeout?: number)
---@field requestAnimSet fun(asset: string, timeout?: number): StreamingHandle
---@field withAnimSet fun(asset: string, fn: fun(asset: string), timeout?: number)
---@field requestTextureDict fun(asset: string, timeout?: number): StreamingHandle
---@field withTextureDict fun(asset: string, fn: fun(asset: string), timeout?: number)
---@field requestPtfxAsset fun(asset: string, timeout?: number): StreamingHandle
---@field withPtfxAsset fun(asset: string, fn: fun(asset: string), timeout?: number)
---@field requestIpl fun(asset: string, timeout?: number): StreamingHandle
---@field withIpl fun(asset: string, fn: fun(asset: string), timeout?: number)
---@field requestWeaponAsset fun(weaponType: string|number, timeout?: number, resourceFlags?: WeaponResourceFlags, componentFlags?: WeaponComponentFlags): StreamingHandle
---@field withWeaponAsset fun(weaponType: string|number, fn: fun(weaponType: number), timeout?: number, resourceFlags?: WeaponResourceFlags, componentFlags?: WeaponComponentFlags)
---@field requestAudioBank fun(audioBank: string, timeout?: number): StreamingHandle
---@field withAudioBank fun(audioBank: string, fn: fun(audioBank: string), timeout?: number)

---@class LogMethods : LogInstance
---@field debug fun(self, message: string, data?: table)
---@field info fun(self, message: string, data?: table)
---@field warn fun(self, message: string, data?: table)
---@field error fun(self, message: string, data?: table)
---@field setLevel fun(self, level: LogLevel)
---@field addHook fun(self, fn: fun(event: LogEvent))
---@field removeHook fun(self, fn: fun(event: LogEvent))
---@field clearHooks fun(self)

---@class TSFXClass
---@field Player fun(source?: number): PlayerHandleClass
---@field Inventory InventoryHandleClass
---@field Notify NotifyHandleClass
---@field EventBus EventBusClass
---@field Cache CacheClass
---@field Framework fun(): FrameworkHandleClass
---@field Locale LocaleClass
---@field Log LogMethods
---@field Streaming StreamingClass
---@field StateMachine fun(name: string, opts: StateMachineOptions): StateMachineClass

---@type TSFXClass
TSFX = {}

---@type fun(key: string, params?: table): string
_ = nil

---@type fun(key: string, params?: table): string
l = nil
