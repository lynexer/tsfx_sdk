--[[
    MODULE: TSFX SDK - Spatial Grid

    A 2D spatial hash grid covering the GTA map bounds.
    Entries are registered across all cells they overlap based on their
    bounding footprint (width/length or radius). Used for broad-phase
    culling to avoid checking every registered entry on every tick.
--]]

-- SECTION: SpatialGrid // ----------------------------------------

---@class SpatialGridClass
local SpatialGrid = {}
SpatialGrid.__index = SpatialGrid

---@return SpatialGridClass
function SpatialGrid.new()
    local self = setmetatable({}, SpatialGrid)

    self._cells = {}
    self._querySet = {}
    self._cache = {}
    self._debugBlips = {}
    self._cellWidth = (_TSFX._MAP.MAX_X - _TSFX._MAP.MIN_X) / _TSFX._GRID.COLS
    self._cellHeight = (_TSFX._MAP.MAX_Y - _TSFX._MAP.MIN_Y) / _TSFX._GRID.ROWS
    self._debugEnabled = false

    return self
end

---Returns the integer cell column for a world X coordinate
---@param x number
---@return number
function SpatialGrid:_col(x)
    return (x - _TSFX._MAP.MIN_X) // self._cellWidth
end

---Returns the integer cell row for a world Y coordinate
---@param y number
---@return number
function SpatialGrid:_row(y)
    return (y - _TSFX._MAP.MIN_Y) // self._cellHeight
end

---Returns the inclusive cell range that a footprint overlaps.
---halfW and halfH are the half-extends of the entry's bounding box.
---@param cx number World-space centroid X
---@param cy number World-space centroid Y
---@param halfW number
---@param halfH number
---@return number minCol, number maxCol, number minRow, number maxRow
function SpatialGrid:_footprint(cx, cy, halfW, halfH)
    return
        (cx - halfW - _TSFX._MAP.MIN_X) // self._cellWidth,
        (cx + halfW - _TSFX._MAP.MIN_X) // self._cellWidth,
        (cy - halfH - _TSFX._MAP.MIN_Y) // self._cellHeight,
        (cy + halfH - _TSFX._MAP.MIN_Y) // self._cellHeight
end

---Derives the half-extents from an entry table
---@param entry SpatialGridEntry
---@return number halfW, number halfH
function SpatialGrid:_extents(entry)
    if entry.width and entry.length then
        return entry.width * 0.5, entry.length * 0.5
    end

    return entry.radius, entry.radius
end

---Returns the appropriate blip colour for an entry count
---@param count number
---@return number
function SpatialGrid:_debugColourForCount(count)
    if count >= 10 then
        return _TSFX._GRID.DEBUG.COLOUR.HIGH
    elseif count >= 5 then
        return _TSFX._GRID.DEBUG.COLOUR.MEDIUM
    elseif count >= 2 then
        return _TSFX._GRID.DEBUG.COLOUR.LOW
    else
        return _TSFX._GRID.DEBUG.COLOUR.EMPTY
    end
end

---Rebuilds all debug blips to match the current grid state.
---Only called when debug is enabled.
function SpatialGrid:_rebuildDebugBlips()
    for _, blip in pairs(self._debugBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end

    table.wipe(self._debugBlips)

    for row, r in pairs(self._cells) do
        for col, cell in pairs(r) do
            if #cell > 0 then
                local cx   = _TSFX._MAP.MIN_X + (col + 0.5) * self._cellWidth
                local cy   = _TSFX._MAP.MIN_Y + (row + 0.5) * self._cellHeight
                local blip = AddBlipForArea(cx, cy, 0.0, self._cellWidth, self._cellHeight)

                SetBlipColour(blip, self:_debugColourForCount(#cell))
                SetBlipAlpha(blip, _TSFX._GRID.DEBUG.ALPHA)
                SetBlipDisplay(blip, 2)

                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString(
                    ('Grid [%d,%d] — %d %s'):format(
                        col, row, #cell, #cell == 1 and 'entry' or 'entries'
                    )
                )
                EndTextCommandSetBlipName(blip)

                self._debugBlips[('%d_%d'):format(row, col)] = blip
            end
        end
    end

    local cellCount = 0
    for _ in pairs(self._debugBlips) do cellCount = cellCount + 1 end
    _TSFX.Log:debug('SpatialGrid debug blips rebuilt', { cells = cellCount })
end

---Registers an entry into every cell it overlaps
---@param entry SpatialGridEntry
---@param resourceName string
function SpatialGrid:add(entry, resourceName)
    assert(entry.position, 'SpatialGrid: entry.position is required')
    assert(entry.radius or (entry.width and entry.length), 'SpatialGrid: entry must have radius, or both with and length')

    entry._resourceName = resourceName

    local halfW, halfH = self:_extents(entry)
    local minCol, maxCol, minRow, maxRow = self:_footprint(
        entry.position.x, entry.position.y, halfW, halfH
    )

    for row = minRow, maxRow do
        local r = self._cells[row]

        if not r then
            r = {}
            self._cells[row] = r
        end

        for col = minCol, maxCol do
            local cell = r[col]

            if not cell then
                cell = {}
                r[col] = cell
            end

            cell[#cell + 1] = entry
        end
    end

    table.wipe(self._cache)
    if self._debugEnabled then self:_rebuildDebugBlips() end
end

---@param entry SpatialGridEntry
function SpatialGrid:remove(entry)
    local halfW, halfH = self:_extents(entry)
    local minCol, maxCol, minRow, maxRow = self:_footprint(
        entry.position.x, entry.position.y, halfW, halfH
    )

    for row = minRow, maxRow do
        local r = self._cells[row]
        if not r then goto nextRow end

        for col = minCol, maxCol do
            local cell = r[col]

            if cell then
                for i = 1, #cell do
                    if cell[i] == entry then
                        table.remove(cell, i)
                        break
                    end
                end

                if #cell == 0 then r[col] = nil end
            end
        end

        if not next(r) then self._cells[row] = nil end
        ::nextRow::
    end

    table.wipe(self._cache)
    if self._debugEnabled then self:_rebuildDebugBlips() end
end

---Returns all unique entries within the cells that overlap the query footprint.
---@param point vector3
---@param queryRadius number Half-extent used to determine which cells to scan
---@param resourceName? string If provided, only entries from this resource are returned
---@return SpatialGridEntry[]
function SpatialGrid:getNearby(point, queryRadius, resourceName)
    local c = self._cache
    local minCol, maxCol, minRow, maxRow = self:_footprint(
        point.x, point.y, queryRadius, queryRadius
    )

    if  c.minCol == minCol and c.maxCol == maxCol and c.minRow == minRow and c.maxRow == maxRow and c.resourceName == resourceName then
        return c.results
    end

    local results = {}
    local n = 0
    table.wipe(self._querySet)

    for row = minRow, maxRow do
        local r = self._cells[row]
        if not r then goto nextRow end

        for col = minCol, maxCol do
            local cell = r[col]

            if cell then
                for i = 1, #cell do
                    local entry = cell[i]

                    if not self._querySet[entry] then
                        self._querySet[entry] = true

                        if not resourceName or entry._resourceName == resourceName then
                            n += 1
                            results[n] = entry
                        end
                    end
                end
            end
        end

        ::nextRow::
    end

    c.minCol = minCol
    c.maxCol = maxCol
    c.minRow = minRow
    c.maxRow = maxRow
    c.resourceName = resourceName
    c.results = results

    return results
end

---Returns the column and row of the cell that contains `point`.
---@param point vector3
---@return number col, number row
function SpatialGrid:getCellAt(point)
    return self:_col(point.x), self:_row(point.y)
end

---Enables or disables grid cell visualiisation on the map.
---When enabled, each occupied cell is drawn as a colour-coded area blip.
---@param enabled boolean
function SpatialGrid:setDebug(enabled)
    if not isClient() then
        _TSFX.Log:warn('SpatialGrid:setDebug() is client-only')
        return
    end

    self._debugEnabled = enabled

    if enabled then
        self:_rebuildDebugBlips()
    else
        for _, blip in pairs(self._debugBlips) do
            if DoesBlipExist(blip) then RemoveBlip(blip) end
        end

        table.wipe(self._debugBlips)
        _TSFX.Log:debug('SpatialGrid debug disabled')
    end
end

-- !SECTION

-- SECTION: GridRegistry // ----------------------------------------

GridRegistry = {}
GridRegistry.__index = GridRegistry

local _grids = {}

---Returns an existing named grid or creates one iif it doesn't exist
---@param name string
---@return SpatialGridClass
local function getGrid(name)
    if not _grids[name] then
        _grids[name] = SpatialGrid.new()
        _TSFX.Log:debug('SpatialGrid created', { name = name })
    end

    return _grids[name]
end

---@param name string
---@param entry SpatialGridEntry
function GridRegistry.add(name, entry)
    local resource = GetInvokingResource() or GetCurrentResourceName()
    getGrid(name):add(entry, resource)
end

---@param name string
---@param entry SpatialGridEntry
function GridRegistry.remove(name, entry)
    getGrid(name):remove(entry)
end

---@param name string
---@param point vector3
---@param queryRadius number
---@param localOnly? boolean
---@return SpatialGridEntry[]
function GridRegistry.getNearby(name, point, queryRadius, localOnly)
    local resource = localOnly
        and (GetInvokingResource() or GetCurrentResourceName())
        or nil

    return getGrid(name):getNearby(point, queryRadius, resource)
end

---@param name string
---@param enabled boolean
function GridRegistry.setDebug(name, enabled)
    getGrid(name):setDebug(enabled)
end

---Direct access for modules within the SDK resource that don't need exports.
---@param name string
---@return SpatialGridClass
function GridRegistry.getGrid(name)
    return getGrid(name)
end

-- !SECTION

return Module and Module('GridRegistry', 'shared')
    :mode('export')
    :exportAs('GridRegistry')
    :impl(GridRegistry)
    :methods(function (m)
        m:add('add', 'remove', 'getNearby', 'setDebug')
    end)
    :build()
