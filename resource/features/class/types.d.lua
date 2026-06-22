--- @meta
-- Type definitions for TSFX Class
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class ClassDef
---@field super ClassDef | nil The parent class. Set by :extends(). Call parent methods via ClassName.super.method(self, ...)
---@field __name string The name passed to Class()
---@field __super ClassDef | nil Internal parent reference used for chain walking.
---@field __abstract boolean True if :abstract() was called
---@field __sealed boolean True if :sealed() was called
---@field __interfaces table List of InterfaceDef obligations inherited and declared on this class
---@field __static table Namespace for static methods. Entries are auto-promoted onto the class as first instantiation
---@field __get table Namespace for getter accessors. Keys are property names, values are function(self)
---@field __set table Namespace for setter accessors. Keys are property names, values are function(self, value)

---@class ClassInstance
---@field __class string The name of the class thisi instance belongs to
