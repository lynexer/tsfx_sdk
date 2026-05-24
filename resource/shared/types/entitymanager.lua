--- @meta
-- Type definitions for TSFX Entity Manager
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias StyledPedSkinComponent { component: number, drawable: number, texture: number }
---@alias StyledPedSkinProps {}
---@alias StyledPedSkinHeadBlend {}
---@alias StyledPedSkinFaceFeatures {}
---@alias StyledPedSkinHeadOverlays {}
---@alias StyledPedSkinHair {}
---@alias StyledPedSkinEyeColour {}
---@alias StyledPedSkinTattoos {}

---@class StyledPedSkin
---@field identifier string
---@field model string
---@field components StyledPedSkinComponent[]
---@field props? StyledPedSkinProps
---@field headBlend? StyledPedSkinHeadBlend
---@field faceFeatures? StyledPedSkinFaceFeatures
---@field headOverlays? StyledPedSkinHeadOverlays
---@field hair? StyledPedSkinHair
---@field eyeColour? StyledPedSkinEyeColour
---@field tattoos? StyledPedSkinTattoos

---@class EntityData
---@field model string|number
---@field position vector4
---@field renderDistance? number
---@field onRender? fun(entity: string)
---@field onDestroy? fun(entity: string)

---@class PedData : EntityData
---@field animation? PedAnimationData
---@field scenario? string

---@class ObjectData : EntityData
---@field placeOnGround? boolean

---@class StyledPedData
---@field skinIdentifier string
---@field position vector4
---@field renderDistance? number
---@field onRender? fun(entity: string)
---@field onDestroy? fun(entity: string)
---@field animation? PedAnimationData
---@field scenario? string

---@class EntityClass
---@field model string|number
---@field position vector4
---@field renderDistance number
---@field isRendered boolean
---@field entity number?
---@field onRender fun(entity: number)?
---@field onDestroy fun(entity: number)?

---@alias PedAnimationData { dict: string, name: string, flag?: number }

---@class PedClass : EntityClass
---@field scenario string?
---@field animation PedAnimationData?

---@class StyledPedClass : PedClass
---@field skin StyledPedSkin

---@class ObjectClass : EntityClass
---@field placeOnGround boolean

---@class EntityManagerClass
---@field entities table<string, PedClass | StyledPedClass | ObjectClass>
---@field pedSkins table<string, StyledPedSkin>
