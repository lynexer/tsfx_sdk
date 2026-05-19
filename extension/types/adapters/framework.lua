--- @meta
-- Type definitions for TSFX Framework Adapter
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias MoneyAccount 'bank' | 'cash' | 'black_money'

---@class PlayerData
---@field source number The player server ID
---@field identifier string The players unique identifier
---@field name string The players display name

---@class LocalPlayerData
---@field source number The player server ID
---@field identifier string The players unique identifier
---@field name string The players display name

---@class JobData
---@field name string Job identifier
---@field label string Job display label
---@field grade number Job grade level
---@field gradeLabel string Grade display label

---@class GangData
---@field name string Gang identifier
---@field label string Gang display label
---@field grade number Gang grade level
---@field gradeLabel string Grade display label

---@class IdentityData
---@field firstName string First name
---@field lastName string Last name
---@field dob string Date of birth
---@field gender string Gender identifier
---@field nationality string|nil Nationality

---@class IdentifierData
---@field license string|nil
---@field steam string|nil
---@field discord string|nil
---@field fivem string|nil
---@field ip string|nil

---@class JobDefinition
---@field name string
---@field label string
---@field grades { [number]: { label: string } }

---@class GangDefinition
---@field name string
---@field label string
---@field grades { [number]: { label: string } }

---@class IFrameworkServer : IAdapter
---@field _getFrameworkPlayer fun(source: number): any
---@field _normalizeAccount fun(account: string): string
---@field getPlayer fun(source: number): PlayerData
---@field getMoney fun(source: number, account: MoneyAccount): number
---@field setMoney fun(source: number, account: MoneyAccount, amount: number)
---@field giveMoney fun(source: number, account: MoneyAccount, amount: number)
---@field takeMoney fun(source: number, account: MoneyAccount, amount: number)
---@field getJob fun(source: number): JobData
---@field setJob fun(source: number, name: string, grade: number)
---@field getOnDuty fun(source: number): boolean
---@field setOnDuty fun(source: number, onDuty: boolean)
---@field getGang fun(source: number): GangData|nil
---@field setGang fun(source: number, name: string, grade: number)
---@field getGroup fun(source: number): string
---@field getIdentity fun(source: number): IdentityData
---@field getIdentifiers fun(source: number): IdentifierData
---@field getMetadata fun(source: number, key: string): any
---@field setMetadata fun(source: number, key: string, value: any)
---@field kick fun(source: number, reason: string)
---@field isLoaded fun(source: number): boolean
---@field save fun(source: number)
---@field requiresSave boolean
---@field getAllPlayers fun(): number[]
---@field getPlayerByIdentifier fun(idType: string, value: string): number|nil
---@field getPlayerByCitizenId fun(citizenId: string): number|nil
---@field getPlayerCount fun(): number
---@field getPlayersByJob fun(jobName: string): number[]
---@field getJobDefinition fun(name: string): JobDefinition|nil
---@field getAllJobs fun(): { [string]: JobDefinition }
---@field getGangDefinition fun(name: string): GangDefinition|nil
---@field getAllGangs fun(): { [string]: GangDefinition }
---@field getFrameworkName fun(): string
---@field getFrameworkVersion fun(): string|nil

---@class IFrameworkClient : IAdapter
---@field isLoaded fun(): boolean
---@field getLocalPlayerData fun(): LocalPlayerData
---@field getLocalJob fun(): JobData
---@field getLocalMoney fun(account: MoneyAccount): number
---@field getLocalGroup fun(): string
---@field getLocalIdentity fun(): IdentityData
---@field getLocalIdentifier fun(): string
---@field getLocalIdentifiers fun(): IdentifierData
---@field getLocalMetadata fun(key: string): any
---@field hasGroup fun(filter: string|string[]): boolean
---@field getGroups fun(): { [string]: number }
---@field getLocalGang fun(): GangData|nil
---@field getLocalOnDuty fun(): boolean
